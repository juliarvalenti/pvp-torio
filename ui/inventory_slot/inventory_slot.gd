extends Control

@export var keybind: int = 1
@export var isSelected: bool = false
@export var itemId: int = 0
@export var quantity: int = 0

@onready var label = $KeybindLabel
@onready var selected_texture = $SelectedTextureRect
@onready var unselected_texture = $UnselectedTextureRect
@onready var quantity_label = $QuantityLabel

func _ready() -> void:
	label.text = str(keybind)
	pass


func _process(_delta: float) -> void:
	quantity_label.text = str(quantity)

	if (isSelected):
		selected_texture.show()
		unselected_texture.hide()
	else:
		selected_texture.hide()
		unselected_texture.show()

	pass
