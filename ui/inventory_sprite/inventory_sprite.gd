extends Control

@export var item_id: int = 0
@onready var texture_rect = $TextureRect

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if (item_id == -1):
		texture_rect.visible = false
		return

	var sprite = Types.item_data[item_id]["sprite"]

	if (sprite == null):
		texture_rect.visible = false
		return

	texture_rect.visible = true
	texture_rect.texture = sprite
	pass
