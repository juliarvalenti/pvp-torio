extends Control

@onready var InventorySlotGrid = $InventorySlotGrid

# 1-indexed keybinds
var selectedKey = 1

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var inventory = Inventory.get_inventory()

	# 0 - 7
	var keys = inventory.keys()
	for key in keys:
		var real_key = key + 1
		if Input.is_action_just_pressed(str(real_key)):
			selectedKey = real_key
			break

	for child in InventorySlotGrid.get_children():
		if child.keybind != selectedKey:
			child.is_selected = false
		else:
			child.is_selected = true

	for slot in inventory.keys():
		var item = inventory[slot]
		var this_item_name = "InventorySlot" + str(slot)

		if item != null:
			$InventorySlotGrid.get_node(this_item_name).item_id = item.item_id
			$InventorySlotGrid.get_node(this_item_name).quantity = item.quantity
		else:
			$InventorySlotGrid.get_node(this_item_name).item_id = -1
			$InventorySlotGrid.get_node(this_item_name).quantity = -1
	pass
