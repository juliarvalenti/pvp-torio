extends CharacterBody2D

enum State {
	IDLE,
	BUILDING
}

var state = State.IDLE
var speed = 8000
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var building_preview: Node2D = $BuildingPreview
var gold_mine: PackedScene = preload("res://gold_mine/gold_mine.tscn")

func _ready():
	building_preview.visible = false

func _physics_process(delta: float) -> void:
	# Get input as a vector and normalize it
	var input_vector = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

	# Calculate velocity using the normalized input vector
	velocity = input_vector * speed * delta

	# Flip sprite only when moving horizontally
	if input_vector.x != 0:
		animated_sprite.flip_h = input_vector.x > 0

	# Play animations based on whether the character is moving
	if input_vector == Vector2.ZERO:
		animated_sprite.play('idle')
		# Snap player position to the grid when idle
		global_position = global_position.snapped(Vector2(8, 8))
	elif input_vector.y > 0:
		animated_sprite.play("walk_d")
	elif input_vector.y < 0:
		animated_sprite.play("walk_u")
	else:
		animated_sprite.play("walk_h")

	move_and_slide()

	match state:
		State.IDLE:
			handle_idle_state(delta)
		State.BUILDING:
			handle_building_state(delta)

func handle_idle_state(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_build"):
		enter_building_mode()

func handle_building_state(_delta: float) -> void:
	# Update building preview position
	var mouse_pos = get_global_mouse_position()
	building_preview.global_position = mouse_pos.snapped(Vector2(8, 8)) + Vector2(4, 4)

	if Input.is_action_just_pressed("ui_click"):
		place_building(mouse_pos)
	if Input.is_action_just_pressed("ui_build"):
		exit_building_mode()

	move_and_slide()

func enter_building_mode() -> void:
	state = State.BUILDING
	building_preview.visible = true

func exit_building_mode() -> void:
	state = State.IDLE
	building_preview.visible = false

func place_building(build_position: Vector2) -> void:
	var building = gold_mine.instantiate()
	building.position = build_position.snapped(Vector2(8, 8))
	get_parent().add_child(building)
