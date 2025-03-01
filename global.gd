extends Node

# Define resource types
enum ResourceType {GOLD, IRON, WOOD, STONE}

# Dictionary to store resources for each player
var resources = {
	1: {ResourceType.GOLD: 0, ResourceType.IRON: 0, ResourceType.WOOD: 0, ResourceType.STONE: 0},
	2: {ResourceType.GOLD: 0, ResourceType.IRON: 0, ResourceType.WOOD: 0, ResourceType.STONE: 0}
}

enum ZLayers {GROUND, BUILDINGS, RESOURCES, PLAYER, UI}

# Function to add resources and update UI
func add_resource(player: int, resource: ResourceType, amount: int):
	if player in resources:
		resources[player][resource] += amount
		update_ui()

# Function to remove resources and update UI
func remove_resource(player: int, resource: ResourceType, amount: int):
	if player in resources and resources[player][resource] >= amount:
		resources[player][resource] -= amount
		update_ui()
			
func update_ui():
	var ui = get_tree().get_root().get_node_or_null("ui")
	if ui:
		ui.update_resource_labels()

# Function to get the current resource count for a player
func get_resource(player: int, resource: ResourceType) -> int:
	if player in resources:
		return resources[player][resource]
	return 0
