import os
import re
import argparse
from pathlib import Path
import pyperclip
import traceback

def extract_node_info(line):
    """Extract node name, type and path from a node definition line"""
    # Matches [node name="Name" type="Type" parent="Path"]
    node_match = re.match(r'\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?(?: instance=ExtResource\("([^"]+)"\))?.*\]', line)
    if node_match:
        name = node_match.group(1)
        type = node_match.group(2)
        parent = node_match.group(3) or ""
        instance_id = node_match.group(4)
        return name, type, parent, instance_id
    return None

def extract_resource_paths(lines):
    """Extract resource paths from ext_resource and sub_resource lines"""
    resource_paths = {}
    
    # Match both script resources and packed scene resources
    ext_resource_pattern = re.compile(r'\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]')
    
    for line in lines:
        match = ext_resource_pattern.match(line.strip())
        if match:
            res_type = match.group(1)
            path = match.group(2)
            resource_id = match.group(3)
            resource_paths[resource_id] = {"type": res_type, "path": path}
    
    return resource_paths

def parse_scene_file(file_path):
    """Parse a Godot scene file and extract node hierarchy and properties"""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    lines = content.split('\n')
    
    # Extract resource paths from ext_resource declarations
    resource_paths = extract_resource_paths(lines)
    
    nodes = []
    current_node = None
    properties = {}
    script_id = None
    instance_id = None
    
    for line in lines:
        line = line.strip()
        
        # Check if this is a node definition
        node_info = extract_node_info(line)
        if node_info:
            if current_node:
                # Store previous node before moving to the next
                node_data = {
                    "name": current_node[0],
                    "type": current_node[1],
                    "parent": current_node[2],
                    "properties": properties
                }
                
                # Add script info if exists
                if script_id and script_id in resource_paths:
                    node_data["script_path"] = resource_paths[script_id]["path"]
                
                # Add instance info if exists
                if instance_id and instance_id in resource_paths:
                    node_data["instance_path"] = resource_paths[instance_id]["path"]
                    node_data["is_instance"] = True
                
                nodes.append(node_data)
                properties = {}
                script_id = None
                instance_id = None
            
            current_node = node_info[:3]  # name, type, parent
            
            # Check if instance_id is provided in node definition
            if len(node_info) > 3 and node_info[3]:
                instance_id = node_info[3]
            continue
        
        # Look for script reference
        script_match = re.match(r'script\s*=\s*ExtResource\("([^"]+)"\)', line)
        if script_match:
            script_id = script_match.group(1)
        
        # Look for instance reference as a property
        instance_match = re.match(r'instance\s*=\s*ExtResource\("([^"]+)"\)', line)
        if instance_match:
            instance_id = instance_match.group(1)
        
        # If we're processing a node, collect its properties
        if current_node and line and not line.startswith('['):
            # Simple property extraction
            prop_match = re.match(r'([^:=]+)\s*=\s*(.+)', line)
            if prop_match:
                prop_name = prop_match.group(1).strip()
                prop_value = prop_match.group(2).strip()
                properties[prop_name] = prop_value
    
    # Add the last node if any
    if current_node:
        node_data = {
            "name": current_node[0],
            "type": current_node[1],
            "parent": current_node[2],
            "properties": properties
        }
        
        # Add script info if exists
        if script_id and script_id in resource_paths:
            node_data["script_path"] = resource_paths[script_id]["path"]
        
        # Add instance info if exists
        if instance_id and instance_id in resource_paths:
            node_data["instance_path"] = resource_paths[instance_id]["path"]
            node_data["is_instance"] = True
            
        nodes.append(node_data)
    
    return nodes, resource_paths

def build_node_tree(nodes):
    """Build a tree structure from the flat node list"""
    # Create a dictionary to map node paths to their node objects
    node_map = {}
    root_nodes = []
    
    # First, create node objects for all nodes
    for node_data in nodes:
        name = node_data["name"]
        node_obj = {
            "name": name,
            "type": node_data["type"],
            "props": node_data.get("properties", {}),
            "children": [],
            "script_path": node_data.get("script_path"),
            "instance_path": node_data.get("instance_path"),
            "is_instance": node_data.get("is_instance", False)
        }
        
        # Add to dictionary keyed by name
        node_map[name] = node_obj
        
        # If no parent, this is a root node
        if not node_data["parent"]:
            root_nodes.append(node_obj)
    
    # Now establish parent-child relationships
    for node_data in nodes:
        name = node_data["name"]
        parent_path = node_data["parent"]
        
        if parent_path:
            # Find the immediate parent node
            path_parts = parent_path.split("/")
            immediate_parent_name = path_parts[-1]
            
            if immediate_parent_name in node_map:
                node_map[immediate_parent_name]["children"].append(node_map[name])
            else:
                # If parent not found, add to root (shouldn't happen in valid scene files)
                root_nodes.append(node_map[name])
    
    return root_nodes

def format_tree(node, prefix="", is_last=True, is_root=True):
    """Format a node tree as a string with tree-like formatting"""
    result = ""
    
    if is_root:
        result += ".\n"
    else:
        connector = "└── " if is_last else "├── "
        node_display = f"{node['name']} ({node['type']})" if node['type'] else node['name']
        
        # Add slash for containers
        if node["children"]:
            node_display += "/"
            
        # Add script indicator if the node has a script
        if node.get("script_path"):
            node_display += " [Scripted]"
            
        # Add instance indicator if the node is an instance
        if node.get("is_instance"):
            scene_name = Path(node.get("instance_path", "")).stem
            node_display += f" [Instance: {scene_name}]"
            
        result += f"{prefix}{connector}{node_display}\n"
    
    # Process children
    child_prefix = prefix + ("    " if is_last or is_root else "│   ")
    children = node["children"]
    
    for i, child in enumerate(children):
        is_last_child = i == len(children) - 1
        result += format_tree(child, child_prefix, is_last_child, False)
    
    return result

def format_node_properties(nodes):
    """Format all node properties as markdown"""
    result = ""
    
    for node_data in nodes:
        name = node_data["name"]
        type_name = node_data["type"]
        props = node_data["properties"]
        script_path = node_data.get("script_path")
        instance_path = node_data.get("instance_path")
        
        if type_name:  # Some nodes might not have a type
            result += f"## {name} ({type_name})\n\n"
        else:
            result += f"## {name}\n\n"
        
        if script_path:
            result += f"**Script**: `{script_path}`\n\n"
        
        if instance_path:
            result += f"**Instance of**: `{instance_path}`\n\n"
            
        if props:
            result += "**Properties:**\n\n"
            for prop, value in props.items():
                result += f"- {prop}: {value}\n"
        else:
            result += "No properties.\n"
        
        result += "\n"
    
    return result

def read_script_content(base_path, script_path):
    """Read the content of a script file referenced in the scene"""
    if not script_path or not script_path.startswith("res://"):
        return None
        
    # Convert res:// path to file system path
    relative_path = script_path.replace("res://", "")
    
    # Determine the project root by working backward from the scene file path
    project_root = Path(base_path).parent
    while not (project_root / "project.godot").exists() and project_root != project_root.parent:
        project_root = project_root.parent
    
    full_path = project_root / relative_path
    
    if not full_path.exists():
        return f"Script file not found: {full_path}"
    
    try:
        with open(full_path, 'r', encoding='utf-8') as file:
            return file.read()
    except Exception as e:
        return f"Error reading script file: {str(e)}"

def format_scripts(base_path, resource_paths):
    """Format all scripts as markdown"""
    result = ""
    
    # Extract only script paths and make a set of unique paths
    script_paths = set()
    for resource_id, resource_info in resource_paths.items():
        if resource_info.get("type") == "Script":
            script_paths.add(resource_info.get("path"))
    
    for script_path in script_paths:
        result += f"## Script: {script_path}\n\n"
        
        content = read_script_content(base_path, script_path)
        if content:
            result += "```gdscript\n"
            result += content
            result += "\n```\n\n"
        else:
            result += "Script content could not be loaded.\n\n"
    
    return result

def process_scene_file(file_path):
    """Process a Godot scene file and return the formatted output"""
    try:
        nodes, script_paths = parse_scene_file(file_path)
        
        # Build the node tree
        tree = build_node_tree(nodes)
        
        # Format the tree structure
        root = {"name": "", "type": "", "children": tree, "props": {}}
        tree_output = format_tree(root)
        
        # Format node properties and scripts
        properties_output = format_node_properties(nodes)
        scripts_output = format_scripts(file_path, script_paths)
        
        result = f"# Scene Documentation: {Path(file_path).name}\n\n"
        result += "## Node Tree\n\n```\n" + tree_output + "```\n\n"
        result += "## Node Properties\n\n" + properties_output
        
        if scripts_output:
            result += "## Attached Scripts\n\n" + scripts_output
        
        return result
    except Exception as e:
        return f"Error processing file: {str(e)}\n{traceback.format_exc()}"

def main():
	parser = argparse.ArgumentParser(description="Convert Godot scene files to LLM-friendly documentation.")
	parser.add_argument("scene_path", help="Path to the Godot scene file")
	parser.add_argument("-o", "--output", help="Output file path (defaults to stdout)")
	parser.add_argument("-d", "--debug", action="store_true", help="Enable debug output")
	parser.add_argument("-p", "--print", action="store_true", help="Print output to console")
	
	args = parser.parse_args()
	
	if not os.path.exists(args.scene_path):
		print(f"Error: File {args.scene_path} not found.")
		return
	
	result = process_scene_file(args.scene_path)
	
	if args.print:
		print(result)
		
	if args.output:
		with open(args.output, 'w', encoding='utf-8') as f:
			f.write(result)
		print(f"Documentation saved to {args.output}")
	else:
		try:
			pyperclip.copy(result)
			print("Documentation copied to clipboard")
		except ImportError:
			print("pyperclip package required for clipboard support. Install with: pip install pyperclip")
			return


if __name__ == "__main__":
    main()
