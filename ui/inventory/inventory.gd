extends Control

@onready var InventorySlotGrid = $InventorySlotGrid

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	var inventory = Items.get_inventory()

	for slot in inventory.keys():
		var item = inventory[slot]
		var this_item_name = "InventorySlot" + str(slot)

		if item != null:
			$InventorySlotGrid.get_node(this_item_name).itemId = item.item_id
			$InventorySlotGrid.get_node(this_item_name).quantity = item.quantity
		else:
			$InventorySlotGrid.get_node(this_item_name).itemId = -1
			$InventorySlotGrid.get_node(this_item_name).quantity = -1
	pass
