extends Node

# Reference the types
var resources = {
		Types.Players.PLAYER_1: {
		Types.Items.GOLD: 0,
		Types.Items.IRON: 0,
		Types.Items.WOOD: 0,
		Types.Items.STONE: 0
	},
		Types.Players.PLAYER_2: {
		Types.Items.GOLD: 0,
		Types.Items.IRON: 0,
		Types.Items.WOOD: 0,
		Types.Items.STONE: 0
	}
}

# Function to add resources and update UI
func add_resource(player: int, resource: int, amount: int):
	if player in resources:
		resources[player][resource] += amount
		update_ui()

# Function to remove resources and update UI
func remove_resource(player: int, resource: int, amount: int):
	if player in resources and resources[player][resource] >= amount:
		resources[player][resource] -= amount
		update_ui()
			
func update_ui():
	var ui = get_tree().get_root().get_node_or_null("ui")
	if ui:
		ui.update_resource_labels()

# Function to get the current resource count for a player
func get_resource(player: int, resource: int) -> int:
	if player in resources:
		return resources[player][resource]
	return 0