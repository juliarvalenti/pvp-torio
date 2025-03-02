extends Node

# Inventory initialization with correct structure
var inventory: Dictionary = {}

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize inventory in _ready to ensure proper setup
	inventory = {
		Types.InventoryItemSlot.ITEM1: null,
		Types.InventoryItemSlot.ITEM2: null,
		Types.InventoryItemSlot.ITEM3: null,
		Types.InventoryItemSlot.ITEM4: null,
		Types.InventoryItemSlot.ITEM5: null,
		Types.InventoryItemSlot.ITEM6: null,
		Types.InventoryItemSlot.ITEM7: null,
		Types.InventoryItemSlot.ITEM8: null,
	}

# Add a single item to inventory, automatically determining the slot
func add_item_to_inventory(item: int, quantity: int = 1):
	# First, check if the item already exists in any slot and can be stacked
	for slot in inventory.keys():
		if inventory[slot] != null and inventory[slot].item_id == item:
			# Found matching item, stack it
			inventory[slot].quantity += quantity
			return true
	
	# If we reach here, item doesn't exist in inventory or couldn't be stacked
	# Find first empty slot
	for slot in inventory.keys():
		if inventory[slot] == null:
			# Found empty slot, add item here
			inventory[slot] = Types.QuantifiedItem.new(item, quantity)
			return true
	
	# If we reach here, inventory is full
	push_error("Cannot add item: inventory is full")
	return false

# Get item at inventory slot
func get_item_at_slot(slot: int) -> Types.QuantifiedItem:
	if inventory.has(slot):
		return inventory[slot]
	return null

func get_inventory() -> Dictionary:
	return inventory
