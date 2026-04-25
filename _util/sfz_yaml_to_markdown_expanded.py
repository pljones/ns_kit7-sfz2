#!/usr/bin/env python3
"""
Parse all SFZ YAML files and generate comprehensive LLM-friendly Markdown documentation.

Processes 7 YAML files in 17+ markdown outputs:
1. syntax.yml - Opcode definitions (11 files)
2. see_also.yml - Opcode cross-references (enriches opcodes)
3. engines.yml - Engine-to-format support matrix (1 file)
4. formats.yml - Audio format specifications (1 file)
5. software.yml - SFZ player/tool catalog (1 file)
6. engines/aria.yml - ARIA engine extensions (1 file)
7. engines/linuxsampler.yml - LinuxSampler implementation (1 file)

Generates organized markdown files covering full SFZ specification scope.
"""

import yaml
import os
import sys
import re
from pathlib import Path
from typing import Dict, List, Optional, Any
from collections import defaultdict


class SFZDocumentationGenerator:
    """Generate comprehensive SFZ documentation from all YAML sources."""
    
    def __init__(self, sfz_docs_path: str = None, output_dir: str = "markdown"):
        self.sfz_docs_path = Path(sfz_docs_path) if sfz_docs_path else Path(__file__).parent.parent / "_td-27kv2_scripts" / "docs" / "sfz"
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load all YAML files
        print("Loading YAML files...")
        self.syntax = self._load_yaml("syntax.yml")
        self.see_also = self._load_yaml("see_also.yml")
        self.engines = self._load_yaml("engines.yml")
        self.formats = self._load_yaml("formats.yml")
        self.software = self._load_yaml("software.yml")
        self.aria = self._load_yaml("engines/aria.yml")
        self.linuxsampler = self._load_yaml("engines/linuxsampler.yml")
        self.warnings = []
        
        # Build indices for cross-referencing
        self._build_indices()
    
    def _load_yaml(self, filename: str) -> Dict:
        """Load YAML file safely."""
        filepath = self.sfz_docs_path / filename
        try:
            with open(filepath, 'r') as f:
                data = yaml.safe_load(f)
                return data if data else {}
        except FileNotFoundError:
            print(f"  ⚠ Warning: {filename} not found")
            return {}
    
    def _build_indices(self):
        """Build lookup indices for cross-referencing."""
        # Build stable output filename maps for syntax categories.
        categories = self.syntax.get('categories', []) if isinstance(self.syntax, dict) else []
        self.category_file_by_index = {}
        self.category_file_by_url = {}
        for idx, category in enumerate(categories, 1):
            category_name = category.get('name', f'Category {idx}')
            filename = f"{idx}-sfz-{self._sanitize_filename(category_name)}.md"
            self.category_file_by_index[idx] = filename
            category_url = category.get('url', '')
            if category_url:
                self.category_file_by_url[category_url] = filename

        # Index headers and opcodes by name, and resolve their output file/anchor.
        self.header_anchor_map = {}
        headers = self.syntax.get('headers', []) if isinstance(self.syntax, dict) else []
        for header in headers:
            header_name = header.get('name', '')
            if header_name:
                self.header_anchor_map[header_name] = self._slugify_anchor(header_name)

        self.opcodes_by_name = {}
        self.opcode_to_link = {}
        self.type_url_to_link = {}
        for category_idx, category in enumerate(categories, 1):
            category_filename = self.category_file_by_index[category_idx]

            opcodes = category.get('opcodes') or []
            for opcode in opcodes:
                opcode_name = opcode.get('name', '')
                if not opcode_name:
                    continue
                self.opcodes_by_name[opcode_name] = opcode
                self.opcode_to_link[opcode_name] = f"{category_filename}#{self._slugify_anchor(opcode_name)}"
            
            types = category.get('types') or []
            for type_def in types:
                type_name = type_def.get('name', '')
                type_url = type_def.get('url', '')
                if type_url:
                    self.type_url_to_link[type_url] = f"{category_filename}#{self._slugify_anchor(type_name)}"

                type_opcodes = type_def.get('opcodes') or []
                for opcode in type_opcodes:
                    opcode_name = opcode.get('name', '')
                    if not opcode_name:
                        continue
                    self.opcodes_by_name[opcode_name] = opcode
                    self.opcode_to_link[opcode_name] = f"{category_filename}#{self._slugify_anchor(opcode_name)}"
        
        # Build see_also index with reciprocal opcode references.
        raw_see_also = defaultdict(set)
        if isinstance(self.see_also, list):
            for entry in self.see_also:
                opcode_name = entry.get('name', '')
                pages = entry.get('pages', [])
                if opcode_name and pages:
                    for page in pages:
                        if not isinstance(page, dict):
                            continue
                        target_name = page.get('name', '')
                        if not target_name or target_name == opcode_name:
                            continue
                        raw_see_also[opcode_name].add(target_name)
                        if opcode_name in self.opcodes_by_name and target_name in self.opcodes_by_name:
                            raw_see_also[target_name].add(opcode_name)

        self.see_also_index = {
            src: sorted(list(targets))
            for src, targets in raw_see_also.items()
            if targets
        }
    
    def _sanitize_filename(self, name: str) -> str:
        """Convert name to safe filename."""
        return name.lower().replace(' ', '_').replace('/', '_').replace('-', '_')

    def _slugify_anchor(self, text: str) -> str:
        """Create predictable markdown anchor slugs."""
        slug = re.sub(r"[^a-zA-Z0-9_\-\s]", "", text or "").strip().lower()
        slug = re.sub(r"\s+", "-", slug)
        slug = re.sub(r"-+", "-", slug)
        return slug

    def _resolve_internal_target(self, target: str) -> Optional[str]:
        """Resolve SFZ-site relative links to generated markdown targets."""
        if not target:
            return None
        if target.startswith("http://") or target.startswith("https://"):
            return target
        if not target.startswith("/"):
            return target

        if target in self.category_file_by_url:
            return self.category_file_by_url[target]

        if target.startswith("/headers/"):
            header_name = target.split("/headers/", 1)[1].split("#", 1)[0]
            if header_name in self.header_anchor_map:
                return f"0-sfz-headers.md#{self.header_anchor_map[header_name]}"

        if target.startswith("/opcodes/"):
            opcode_name = target.split("/opcodes/", 1)[1]
            if not opcode_name or "?" in opcode_name:
                return None
            return self.opcode_to_link.get(opcode_name)

        if target.startswith("/misc/categories"):
            return self.category_file_by_url.get(target)

        if target in self.type_url_to_link:
            return self.type_url_to_link[target]

        return None

    def _normalize_internal_links(self, text: str, context: str = "") -> str:
        """Rewrite internal links to generated markdown targets."""
        if not text or not isinstance(text, str):
            return text

        def replace_href_single(match):
            url = match.group(1)
            resolved = self._resolve_internal_target(url)
            if resolved:
                return f"href='{resolved}'"
            if url.startswith("/"):
                self.warnings.append(f"Unresolved internal link in {context}: {url}")
            return match.group(0)

        def replace_href_double(match):
            url = match.group(1)
            resolved = self._resolve_internal_target(url)
            if resolved:
                return f'href="{resolved}"'
            if url.startswith("/"):
                self.warnings.append(f"Unresolved internal link in {context}: {url}")
            return match.group(0)

        def replace_markdown_link(match):
            label = match.group(1)
            url = match.group(2)
            resolved = self._resolve_internal_target(url)
            if resolved:
                return f"[{label}]({resolved})"
            if url.startswith("/"):
                self.warnings.append(f"Unresolved markdown link in {context}: {url}")
            return match.group(0)

        text = re.sub(r"href='([^']+)'", replace_href_single, text)
        text = re.sub(r'href="([^"]+)"', replace_href_double, text)
        text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", replace_markdown_link, text)
        return text
    
    def _format_value_info(self, value: Optional[Dict], context: str = "") -> str:
        """Format opcode value/parameter information."""
        if not value:
            return ""
        
        lines = []
        
        if 'type_name' in value:
            lines.append(f"**Type:** `{value['type_name']}`")
        
        if 'default' in value:
            default_value = self._normalize_internal_links(str(value['default']), f"{context}:default")
            lines.append(f"**Default:** `{default_value}`")
        
        if 'min' in value and 'max' in value:
            lines.append(f"**Range:** `{value['min']}` to `{value['max']}`")
        
        if 'unit' in value:
            unit_value = self._normalize_internal_links(str(value['unit']), f"{context}:unit")
            lines.append(f"**Unit:** {unit_value}")
        
        return "\n".join(lines)
    
    def _format_modulation_info(self, modulation: Optional[Dict]) -> str:
        """Format modulation information."""
        if not modulation:
            return ""
        
        lines = ["#### Modulation"]
        
        midi_cc = modulation.get('midi_cc') or []
        if midi_cc:
            lines.append("**MIDI CC Modulation:**")
            for mod in midi_cc:
                mod_name = mod.get('name', '')
                mod_desc = self._normalize_internal_links(mod.get('short_description', ''), f"modulation:{mod_name}")
                lines.append(f"- `{mod_name}`: {mod_desc}")
        
        return "\n".join(lines)
    
    def _format_opcode_markdown(self, opcode: Dict, heading_level: int = 2) -> str:
        """Format single opcode with enriched see_also references."""
        name = opcode.get('name', '')
        desc = self._normalize_internal_links(opcode.get('short_description', ''), f"opcode:{name}")
        version = opcode.get('version', '')
        value = opcode.get('value')
        modulation = opcode.get('modulation')
        section_heading = "#" * max(2, heading_level)
        sub_section_heading = "#" * min(6, max(3, heading_level + 1))
        
        lines = [f"{section_heading} {name}"]
        
        if desc:
            lines.append(f"\n{desc}")
        
        if version:
            lines.append(f"\n**Version:** {version}")
        
        value_info = self._format_value_info(value, f"opcode:{name}")
        if value_info:
            lines.append(f"\n{value_info}")
        
        mod_info = self._format_modulation_info(modulation)
        if mod_info:
            mod_info = mod_info.replace("#### ", f"{sub_section_heading} ")
            lines.append(f"\n{mod_info}")
        
        # Add see_also references if available
        if name in self.see_also_index:
            related = self.see_also_index[name]
            if related:
                lines.append(f"\n{sub_section_heading} See Also")
                for opcode_name in related:
                    link = self.opcode_to_link.get(opcode_name)
                    if link:
                        lines.append(f"- [{opcode_name}]({link})")
                    else:
                        if "*" in opcode_name:
                            self.warnings.append(f"Wildcard see_also target for {name}: {opcode_name}")
                        else:
                            self.warnings.append(f"Non-opcode see_also target for {name}: {opcode_name}")
                        lines.append(f"- `{opcode_name}`")
        
        lines.append("")
        return "\n".join(lines)
    
    def generate_syntax_files(self):
        """Generate markdown files from syntax.yml."""
        print("\n📄 Generating SFZ Syntax Documentation...")
        
        # Generate headers file
        headers_md = self._generate_headers_markdown()
        headers_file = self.output_dir / "0-sfz-headers.md"
        with open(headers_file, 'w') as f:
            f.write(headers_md)
        print(f"  ✓ {headers_file.name}")
        
        # Generate category files
        categories = self.syntax.get('categories') or []
        for idx, category in enumerate(categories, 1):
            category_name = category.get('name', f'Category {idx}')
            safe_name = self._sanitize_filename(category_name)
            filename = f"{idx}-sfz-{safe_name}.md"
            filepath = self.output_dir / filename
            
            category_md = self._generate_category_markdown(category)
            with open(filepath, 'w') as f:
                f.write(category_md)
            print(f"  ✓ {filepath.name}")
    
    def _generate_headers_markdown(self) -> str:
        """Generate SFZ headers documentation."""
        lines = [
            "# SFZ Headers",
            "",
            "SFZ headers define structural sections within SFZ files. Each header contains related opcodes and parameters.",
            ""
        ]
        
        headers = self.syntax.get('headers') or []
        for header in headers:
            name = header.get('name', '')
            desc = self._normalize_internal_links(header.get('short_description', ''), f"header:{name}")
            version = header.get('version', '')
            deprecated = header.get('deprecated', False)
            
            lines.append(f"## {name}")
            
            if desc:
                lines.append(f"\n{desc}")
            
            if version:
                lines.append(f"\n**Version:** {version}")
            
            if deprecated:
                lines.append("\n⚠️ **Deprecated**")
            
            lines.append("")
        
        return "\n".join(lines)
    
    def _generate_category_markdown(self, category: Dict) -> str:
        """Generate markdown for a category."""
        category_name = category.get('name', 'Unknown')
        category_desc = self._normalize_internal_links(category.get('short_description', ''), f"category:{category_name}")
        
        lines = [f"# {category_name}", ""]
        
        if category_desc:
            lines.append(category_desc)
            lines.append("")
        
        # Check if category has types
        types = category.get('types') or []
        if types:
            # Generate by type
            for type_def in types:
                type_name = type_def.get('name', '')
                type_desc = self._normalize_internal_links(type_def.get('short_description', ''), f"type:{type_name}")
                
                if type_name:
                    lines.append(f"## {type_name}")
                    if type_desc:
                        lines.append(f"\n{type_desc}\n")
                
                opcodes = type_def.get('opcodes') or []
                for opcode in opcodes:
                    lines.append(self._format_opcode_markdown(opcode, heading_level=3))
        else:
            # Generate opcodes directly
            opcodes = category.get('opcodes') or []
            for opcode in opcodes:
                lines.append(self._format_opcode_markdown(opcode, heading_level=2))
        
        return "\n".join(lines)
    
    def generate_engine_compatibility(self):
        """Generate merged engine compatibility + audio formats document."""
        print("\n⚙️ Generating Engine/Format Documentation...")
        
        engines_data = self.engines if isinstance(self.engines, list) else []
        if not engines_data:
            print("  ⚠ No engine data available")
            return
        
        lines = [
            "# SFZ Engine Compatibility Matrix",
            "",
            "This document shows which SFZ engines support which audio formats.",
            ""
        ]

        format_meta = {
            item.get('name', ''): item
            for item in (self.formats if isinstance(self.formats, list) else [])
            if isinstance(item, dict) and item.get('name')
        }
        
        # Build compatibility table
        formats_set = set()
        for engine in engines_data:
            supported = [f.get('name', '') for f in engine.get('formats', []) if isinstance(f, dict)]
            formats_set.update(supported)
        formats_set.update(format_meta.keys())
        
        formats_list = sorted(list(formats_set))
        
        # Table header
        display_formats = []
        for fmt in formats_list:
            marker = "*" if format_meta.get(fmt, {}).get('lossy') else ""
            display_formats.append(f"{fmt}{marker}")

        lines.append("| Engine | " + " | ".join(display_formats) + " |")
        lines.append("|--------|" + "|".join(["-----"] * len(formats_list)) + "|")
        
        # Table rows
        for engine in engines_data:
            engine_name = engine.get('name', '')
            engine_formats = [f.get('name', '') for f in engine.get('formats', []) if isinstance(f, dict)]
            row = [engine_name]
            for fmt in formats_list:
                supported = fmt in engine_formats
                row.append("✓" if supported else "✗")
            lines.append("| " + " | ".join(row) + " |")
        
        lines.append("")
        lines.append("**Legend:** ✓ = Supported, ✗ = Not Supported")
        lines.append("")
        lines.append("* = lossy")

        if format_meta:
            lines.append("")
            lines.append("## Audio Formats")
            lines.append("")
            for fmt in formats_list:
                info = format_meta.get(fmt, {})
                if not info:
                    continue
                suffix = "*" if info.get('lossy') else ""
                lines.append(f"### {fmt}{suffix}")
                lines.append("")
                short_description = info.get('short_description', '')
                if short_description:
                    lines.append(self._normalize_internal_links(short_description, f"format:{fmt}"))
                    lines.append("")
        
        filepath = self.output_dir / "12-engine-compatibility.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")
    
    def generate_audio_formats(self):
        """Formats are emitted in merged engine compatibility document."""
        print("\n🎵 Skipping standalone audio format document (merged into 12-engine-compatibility.md)")
    
    def generate_software_catalog(self):
        """Generate SFZ software/player catalog."""
        print("\n💾 Generating Software Catalog...")
        
        if not isinstance(self.software, dict):
            print("  ⚠ No software data available")
            return
            
        categories = self.software.get('categories', [])
        if not categories:
            print("  ⚠ No software categories available")
            return
        
        lines = [
            "# SFZ Software & Players",
            "",
            "Catalog of SFZ-compatible software, samplers, and tools.",
            ""
        ]
        
        # Process categories
        for category in categories:
            category_name = category.get('name', 'Other')
            applications = category.get('applications', [])
            
            lines.append(f"## {category_name}")
            lines.append("")
            
            for soft in applications:
                name = soft.get('name', '')
                url = soft.get('url', '')
                desc = soft.get('short_description', '')
                platforms = [item.get('name', '') for item in soft.get('os', []) if isinstance(item, dict) and item.get('name')]
                
                if url:
                    lines.append(f"### [{name}]({url})")
                else:
                    lines.append(f"### {name}")
                
                if desc:
                    lines.append(f"\n{desc}")
                
                if platforms:
                    lines.append(f"\n**Platforms:** {', '.join(platforms)}")
                
                lines.append("")
        
        filepath = self.output_dir / "14-software-catalog.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")

    def generate_see_also_reference(self):
        """Generate see-also cross-reference file."""
        print("\n🔗 Generating See Also Cross-Reference...")

        if not isinstance(self.see_also, list) or not self.see_also:
            print("  ⚠ No see_also data available")
            return

        lines = [
            "# SFZ See Also Cross-Reference",
            "",
            "Cross-reference index from `see_also.yml` for related opcodes and resources.",
            ""
        ]

        lines.append("| Opcode | Related Pages |")
        lines.append("|--------|---------------|")
        for entry in self.see_also:
            opcode_name = entry.get('name', '')
            pages = entry.get('pages', [])
            if not opcode_name:
                continue

            related = []
            for page in pages:
                if not isinstance(page, dict):
                    continue
                page_name = page.get('name', '')
                page_url = page.get('url', '')
                if not page_name:
                    continue
                if page_url:
                    related.append(f"[{page_name}]({page_url})")
                else:
                    related.append(f"`{page_name}`")

            lines.append(f"| `{opcode_name}` | {', '.join(related) if related else '-'} |")

        filepath = self.output_dir / "11-sfz-see_also.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")
    
    def generate_aria_extensions(self):
        """Generate ARIA engine extensions documentation."""
        print("\n✨ Generating ARIA Extensions Documentation...")
        
        if not isinstance(self.aria, dict) or not self.aria:
            print("  ⚠ No ARIA data available")
            return
        
        lines = [
            "# ARIA Engine Extensions",
            "",
            "SFZ 2.0 extensions specific to the ARIA engine.",
            ""
        ]
        
        # ARIA file is a flat root with metadata and opcodes.
        aria_name = self.aria.get('name', 'ARIA')
        aria_url = self.aria.get('url', '')
        aria_license = self.aria.get('license', '')
        aria_versions = self.aria.get('versions', [])
        aria_os = [item.get('name', '') for item in self.aria.get('os', []) if isinstance(item, dict) and item.get('name')]

        lines.append(f"**Engine:** {aria_name}")
        if aria_url:
            lines.append(f"**URL:** {aria_url}")
        if aria_license:
            lines.append(f"**License:** {aria_license}")
        if aria_versions:
            lines.append(f"**Versions:** {', '.join(aria_versions)}")
        if aria_os:
            lines.append(f"**Platforms:** {', '.join(aria_os)}")
        lines.append("")

        # Check structure - ARIA may also include category groupings.
        categories = self.aria.get('categories', [])
        if categories:
            for category in categories:
                category_name = category.get('name', '')
                category_desc = category.get('short_description', '')
                
                lines.append(f"## {category_name}")
                if category_desc:
                    lines.append(f"\n{category_desc}\n")
                
                opcodes = category.get('opcodes', [])
                for opcode in opcodes:
                    lines.append(self._format_opcode_markdown(opcode))
        else:
            lines.append("## Supported ARIA Opcodes")
            lines.append("")
            opcodes = [item.get('name', '') for item in self.aria.get('opcodes', []) if isinstance(item, dict) and item.get('name')]
            for name in opcodes:
                lines.append(f"- `{name}`")
        
        filepath = self.output_dir / "15-aria-extensions.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")
    
    def generate_linuxsampler_guide(self):
        """Generate LinuxSampler implementation details."""
        print("\n🐧 Generating LinuxSampler Implementation Guide...")
        
        if not isinstance(self.linuxsampler, dict) or not self.linuxsampler:
            print("  ⚠ No LinuxSampler data available")
            return
        
        lines = [
            "# LinuxSampler Implementation Details",
            "",
            "SFZ support and implementation specifics for LinuxSampler.",
            ""
        ]
        
        # LinuxSampler file is a flat root with metadata and opcode groups.
        ls_name = self.linuxsampler.get('name', 'LinuxSampler')
        ls_url = self.linuxsampler.get('url', '')
        ls_license = self.linuxsampler.get('license', '')
        ls_versions = self.linuxsampler.get('versions', [])
        ls_os = [item.get('name', '') for item in self.linuxsampler.get('os', []) if isinstance(item, dict) and item.get('name')]

        lines.append(f"**Engine:** {ls_name}")
        if ls_url:
            lines.append(f"**URL:** {ls_url}")
        if ls_license:
            lines.append(f"**License:** {ls_license}")
        if ls_versions:
            lines.append(f"**Versions:** {', '.join(ls_versions)}")
        if ls_os:
            lines.append(f"**Platforms:** {', '.join(ls_os)}")
        lines.append("")

        # Check structure
        features = self.linuxsampler.get('features', [])
        limitations = self.linuxsampler.get('limitations', [])
        implementations = self.linuxsampler.get('implementations', [])
        
        if features:
            lines.append("## Supported Features")
            lines.append("")
            for feature in features:
                name = feature.get('name', '')
                desc = feature.get('short_description', '')
                if name:
                    lines.append(f"- **{name}**: {desc}")
            lines.append("")
        
        if limitations:
            lines.append("## Known Limitations")
            lines.append("")
            for limit in limitations:
                name = limit.get('name', '')
                desc = limit.get('description', '')
                if name:
                    lines.append(f"- **{name}**: {desc}")
            lines.append("")
        
        if implementations:
            lines.append("## Implementation Details")
            lines.append("")
            for impl in implementations:
                name = impl.get('name', '')
                desc = impl.get('description', '')
                if name:
                    lines.append(f"### {name}")
                    if desc:
                        lines.append(f"\n{desc}\n")

        opcodes = [item.get('name', '') for item in self.linuxsampler.get('opcodes', []) if isinstance(item, dict) and item.get('name')]
        if opcodes:
            lines.append("## Supported Opcodes")
            lines.append("")
            for name in opcodes:
                lines.append(f"- `{name}`")
            lines.append("")

        fil_types = [item.get('name', '') for item in self.linuxsampler.get('fil_types', []) if isinstance(item, dict) and item.get('name')]
        if fil_types:
            lines.append("## Supported Filter Types (`fil_type`)")
            lines.append("")
            for name in fil_types:
                lines.append(f"- `{name}`")
            lines.append("")
        
        filepath = self.output_dir / "16-linuxsampler-guide.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")

    def generate_sfz_index(self):
        """Generate top-level index with inventory and consistency checks."""
        print("\n📚 Generating SFZ Index...")

        syntax_versions = set(self.syntax.get('versions', [])) if isinstance(self.syntax, dict) else set()
        engine_names = set()
        if isinstance(self.engines, list):
            engine_names = {e.get('name', '') for e in self.engines if isinstance(e, dict) and e.get('name')}

        software_names = set()
        if isinstance(self.software, dict):
            for category in self.software.get('categories', []):
                if not isinstance(category, dict):
                    continue
                for app in category.get('applications', []):
                    if isinstance(app, dict) and app.get('name'):
                        software_names.add(app.get('name'))

        engine_overlay_names = set()
        if isinstance(self.aria, dict) and self.aria.get('name'):
            engine_overlay_names.add(self.aria.get('name'))
        if isinstance(self.linuxsampler, dict) and self.linuxsampler.get('name'):
            engine_overlay_names.add(self.linuxsampler.get('name'))

        known_engine_universe = engine_names.union(engine_overlay_names)
        syntax_engine_overlap = sorted(syntax_versions.intersection(known_engine_universe))
        syntax_without_engine = sorted(syntax_versions.difference(known_engine_universe))
        engines_without_overlay = sorted(engine_names.difference(engine_overlay_names))

        format_names = []
        if isinstance(self.formats, list):
            format_names = [f.get('name', '') for f in self.formats if isinstance(f, dict) and f.get('name')]

        lines = [
            "# SFZ Markdown Documentation Index",
            "",
            "Generated index for SFZ docs, source relationships, and consistency checks.",
            ""
        ]

        lines.append("## Source Files")
        lines.append("")
        lines.append("- `syntax.yml` - Core SFZ headers/opcodes and version tags")
        lines.append("- `see_also.yml` - Cross-reference mapping")
        lines.append("- `engines.yml` - Engine to format support mapping")
        lines.append("- `formats.yml` - Canonical audio format list")
        lines.append("- `software.yml` - Software catalog")
        lines.append("- `engines/aria.yml` - ARIA overlay")
        lines.append("- `engines/linuxsampler.yml` - LinuxSampler overlay")
        lines.append("")

        lines.append("## Generated File Inventory")
        lines.append("")
        generated_files = sorted([p.name for p in self.output_dir.glob("*.md")])
        for name in generated_files:
            lines.append(f"- `{name}`")
        lines.append("")

        lines.append("## Engine/Format Relationship")
        lines.append("")
        lines.append(f"- Formats in `formats.yml`: {', '.join(sorted(format_names)) if format_names else '-'}")
        lines.append(f"- Engines in `engines.yml`: {', '.join(sorted(engine_names)) if engine_names else '-'}")
        lines.append(f"- Software entries in `software.yml`: {len(software_names)}")
        lines.append("")

        lines.append("## Consistency Checks")
        lines.append("")
        lines.append(f"- Syntax versions: {', '.join(sorted(syntax_versions)) if syntax_versions else '-'}")
        lines.append(f"- Overlap with known engines: {', '.join(syntax_engine_overlap) if syntax_engine_overlap else '-'}")
        lines.append(f"- Syntax versions without direct engine match: {', '.join(syntax_without_engine) if syntax_without_engine else '-'}")
        lines.append(f"- Engines without per-engine overlay file: {', '.join(engines_without_overlay) if engines_without_overlay else '-'}")
        lines.append("")

        filepath = self.output_dir / "sfz-index.md"
        with open(filepath, 'w') as f:
            f.write("\n".join(lines))
        print(f"  ✓ {filepath.name}")
    
    def generate_all(self):
        """Generate all documentation files."""
        print("\n" + "="*60)
        print("SFZ YAML to Markdown (Comprehensive)")
        print("="*60)
        
        self.generate_syntax_files()
        self.generate_engine_compatibility()
        self.generate_software_catalog()
        self.generate_aria_extensions()
        self.generate_linuxsampler_guide()
        self.generate_sfz_index()

        stale_files = [
            self.output_dir / "11-sfz-see_also.md",
            self.output_dir / "13-audio-formats.md",
        ]
        for stale in stale_files:
            if stale.exists():
                stale.unlink()
                print(f"  • Removed retired output: {stale.name}")

        if self.warnings:
            print("\n⚠ Validation warnings:")
            for warning in sorted(set(self.warnings)):
                print(f"  - {warning}")
        
        print("\n" + "="*60)
        print(f"✅ Documentation complete! Generated in:")
        print(f"   {self.output_dir}")
        print("="*60)


def main():
    """Main entry point."""
    sfz_docs = "/home/peter/sfz/ns_kit7-sfz2/_td-27kv2_scripts/docs/sfz"
    output_dir = "/home/peter/sfz/ns_kit7-sfz2/_td-27kv2_scripts/docs/sfz_markdown"
    
    if not Path(sfz_docs).exists():
        print(f"Error: {sfz_docs} not found")
        sys.exit(1)
    
    generator = SFZDocumentationGenerator(sfz_docs, output_dir)
    generator.generate_all()


if __name__ == "__main__":
    main()
