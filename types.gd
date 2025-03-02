extends Node

# Resource and item enums
enum Items {
	GOLD, IRON, WOOD, STONE
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