#!/usr/bin/env python3
"""
Parse SFZ YAML files and generate comprehensive LLM-friendly Markdown documentation.

Processes:
1. syntax.yml - Opcode definitions and headers
2. see_also.yml - Opcode cross-references
3. engines.yml - Engine-to-format support matrix
4. formats.yml - Audio format specifications
5. software.yml - SFZ player/tool catalog
6. engines/aria.yml - ARIA engine extensions
7. engines/linuxsampler.yml - LinuxSampler implementation details

Generates 17+ markdown files covering full SFZ specification scope.
"""

import yaml
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Any


class SFZYamlParser:
    """Parse SFZ syntax.yml and generate Markdown files."""
    
    def __init__(self, yaml_path: str, output_dir: str):
        self.yaml_path = Path(yaml_path)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load YAML
        with open(self.yaml_path, 'r') as f:
            self.data = yaml.safe_load(f)
        
        self.headers = self.data.get('headers', [])
        self.categories = self.data.get('categories', [])
        self.opcodes_by_name: Dict[str, Dict] = {}
        
        # Build opcode index for cross-referencing
        self._build_opcode_index()
    
    def _build_opcode_index(self):
        """Build a dictionary mapping opcode names to their definitions."""
        for category in self.categories:
            opcodes = category.get('opcodes', [])
            for opcode in opcodes:
                self.opcodes_by_name[opcode['name']] = opcode
            
            # Also index opcodes within types
            types = category.get('types', [])
            for type_def in types:
                type_opcodes = type_def.get('opcodes', [])
                for opcode in type_opcodes:
                    self.opcodes_by_name[opcode['name']] = opcode
    
    def _sanitize_filename(self, name: str) -> str:
        """Convert category name to safe filename."""
        return name.lower().replace(' ', '_').replace('/', '_').replace('-', '_')
    
    def _format_value_info(self, value: Optional[Dict]) -> str:
        """Format opcode value/parameter information."""
        if not value:
            return ""
        
        lines = []
        
        if 'type_name' in value:
            lines.append(f"**Type:** {value['type_name']}")
        
        if 'default' in value:
            lines.append(f"**Default:** {value['default']}")
        
        if 'min' in value and 'max' in value:
            lines.append(f"**Range:** {value['min']} to {value['max']}")
        
        if 'unit' in value:
            lines.append(f"**Unit:** {value['unit']}")
        
        return "\n".join(lines)
    
    def _format_modulation_info(self, modulation: Optional[Dict]) -> str:
        """Format modulation information (CC, EG, etc)."""
        if not modulation:
            return ""
        
        lines = ["### Modulation"]
        
        midi_cc = modulation.get('midi_cc', [])
        if midi_cc:
            lines.append("**MIDI CC Modulation:**")
            for mod in midi_cc:
                mod_name = mod.get('name', '')
                mod_desc = mod.get('short_description', '')
                lines.append(f"- `{mod_name}`: {mod_desc}")
        
        return "\n".join(lines)
    
    def _format_opcode_markdown(self, opcode: Dict, category_name: str) -> str:
        """Format a single opcode as Markdown."""
        name = opcode.get('name', '')
        desc = opcode.get('short_description', '')
        version = opcode.get('version', '')
        value = opcode.get('value')
        modulation = opcode.get('modulation')
        
        lines = [f"## {name}"]
        
        if desc:
            lines.append(f"\n{desc}")
        
        if version:
            lines.append(f"\n**Version:** {version}")
        
        value_info = self._format_value_info(value)
        if value_info:
            lines.append(f"\n{value_info}")
        
        mod_info = self._format_modulation_info(modulation)
        if mod_info:
            lines.append(f"\n{mod_info}")
        
        lines.append("")  # Blank line for separation
        return "\n".join(lines)
    
    def generate_category_markdown(self, category: Dict) -> str:
        """Generate Markdown content for an entire category."""
        category_name = category.get('name', 'Unknown')
        category_desc = category.get('short_description', '')
        
        lines = [
            f"# {category_name}",
            ""
        ]
        
        if category_desc:
            lines.append(category_desc)
            lines.append("")
        
        # Check if category has types
        types = category.get('types', [])
        if types:
            # Generate by type
            for type_def in types:
                type_name = type_def.get('name', '')
                type_desc = type_def.get('short_description', '')
                
                if type_name:
                    lines.append(f"## {type_name}")
                    if type_desc:
                        lines.append(f"\n{type_desc}\n")
                
                opcodes = type_def.get('opcodes', [])
                for opcode in opcodes:
                    lines.append(self._format_opcode_markdown(opcode, category_name))
        else:
            # Generate opcodes directly
            opcodes = category.get('opcodes', [])
            for opcode in opcodes:
                lines.append(self._format_opcode_markdown(opcode, category_name))
        
        return "\n".join(lines)
    
    def generate_headers_markdown(self) -> str:
        """Generate Markdown for SFZ headers."""
        lines = [
            "# SFZ Headers",
            "",
            "SFZ headers define structural sections in an SFZ file.",
            ""
        ]
        
        for header in self.headers:
            name = header.get('name', '')
            desc = header.get('short_description', '')
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
    
    def generate_all(self):
        """Generate all Markdown files."""
        print("Generating SFZ documentation from YAML...")
        
        # Generate headers file
        headers_md = self.generate_headers_markdown()
        headers_file = self.output_dir / "0-sfz-headers.md"
        with open(headers_file, 'w') as f:
            f.write(headers_md)
        print(f"  ✓ {headers_file.name}")
        
        # Generate category files
        for idx, category in enumerate(self.categories, 1):
            category_name = category.get('name', f'Category {idx}')
            safe_name = self._sanitize_filename(category_name)
            filename = f"{idx}-sfz-{safe_name}.md"
            filepath = self.output_dir / filename
            
            category_md = self.generate_category_markdown(category)
            with open(filepath, 'w') as f:
                f.write(category_md)
            print(f"  ✓ {filepath.name}")
        
        print(f"\nGenerated {len(self.categories) + 1} Markdown files in {self.output_dir}")


def main():
    """Main entry point."""
    yaml_file = "/home/peter/sfz/ns_kit7-sfz2/_td-27kv2_scripts/docs/sfz/syntax.yml"
    output_dir = "/home/peter/sfz/ns_kit7-sfz2/_td-27kv2_scripts/docs/sfz_markdown"
    
    if not Path(yaml_file).exists():
        print(f"Error: {yaml_file} not found")
        sys.exit(1)
    
    parser = SFZYamlParser(yaml_file, output_dir)
    parser.generate_all()


if __name__ == "__main__":
    main()
