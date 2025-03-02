extends Node

# Resource and item enums
enum Items {
	GOLD, IRON, WOOD, STONE
}

var item_data: Dictionary = {
	Items.GOLD: {
		"name": "Gold",
		"texture": preload("res://assets/gold.png"),
		"sprite": preload("res://assets/gold.png")
	},
	Items.IRON: {
		"name": "Iron",
		"texture": preload("res://assets/iron.png"),
		"sprite": preload("res://assets/iron.png")
	},
	Items.WOOD: {
		"name": "Wood",
		"texture": preload("res://assets/wood.png"),
		"sprite": preload("res://assets/wood.png")
	},
	Items.STONE: {
		"name": "Stone",
		"texture": preload("res://assets/stone.png"),
		"sprite": preload("res://assets/stone.png")
	}
}

enum ResourceType {GOLD, IRON, WOOD, STONE}

enum InventoryItemSlot {
	ITEM1, ITEM2, ITEM3, ITEM4, ITEM5, ITEM6, ITEM7, ITEM8
}

# Z-ordering for rendering
enum ZLayers {
	GROUND, BUILDINGS, RESOURCES, PLAYER, UI
}

# Player identification
enum Players {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

class QuantifiedItem:
	var item_id: int # Items enum
	var quantity: int
	
	func _init(id: int, qty: int = 1):
		item_id = id
		quantity = qty