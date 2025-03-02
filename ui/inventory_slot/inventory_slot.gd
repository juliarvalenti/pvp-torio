extends Control

@export var keybind: int = 1
@export var is_selected: bool = false
@export var item_id: int = -1
@export var quantity: int = 0

@onready var label = $KeybindLabel
@onready var selected_texture = $SelectedTextureRect
@onready var unselected_texture = $UnselectedTextureRect
@onready var quantity_label = $QuantityLabel
@onready var inventory_sprite = $GridContainer/InventorySprite

func _ready() -> void:
	label.text = str(keybind)
	pass

func _process(_delta: float) -> void:
	quantity_label.text = str(quantity)
	inventory_sprite.item_id = item_id


	if quantity == 0 or quantity == -1:
		quantity_label.hide()
	else:
		quantity_label.show()

	if (is_selected):
		selected_texture.show()
		unselected_texture.hide()
	else:
		selected_texture.hide()
		unselected_texture.show()
	pass

func enable_empty_state() -> void:
	quantity_label.hide()
	inventory_sprite.item_id = -1
	pass
