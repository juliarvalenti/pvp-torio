extends Node2D

# Scales the launch distance
@export var parent_size: float = 100.0
# Base launch velocity
@export var launch_speed: float = 20.0
# Maximum height of the arc
@export var arc_height: float = 10.0
# Duration of the coin’s travel
@export var lifetime: float = 0.6

# Resource type to drop on collision
@export var resource_type: Types.ResourceType = Types.ResourceType.GOLD
@export var num_resources: int = 1

var start_position: Vector2
var target_position: Vector2
var elapsed_time: float = 0.0
var moving: bool = true # Controls whether the coin is in motion
var collected: bool = false # Ensure the item is only collectable once
var velocity: Vector2 = Vector2.ZERO # Explicitly declare velocity

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_container: Node2D = $SpriteContainer
@export var resource_sprite_scene: PackedScene

func _ready():
	# Get all Sprite2D nodes in the container
	var sprites = sprite_container.get_children().filter(func(n): return n is Sprite2D)
	
	if sprites.is_empty():
			push_error("with_resource_item requires at least one Sprite2D inside SpriteContainer")
	elif sprites.size() == 1:
			# Only the placeholder exists
			if resource_sprite_scene:
					var resource_sprite = resource_sprite_scene.instantiate()
					sprite_container.add_child(resource_sprite)
					sprites[0].visible = false # Hide the placeholder
			else:
					push_warning("No resource sprite assigned in the inspector!")
	else:
			# If multiple sprites exist, assume the first is the placeholder
			var placeholder = sprites[0]
			placeholder.visible = false
	
	# Store initial position
	start_position = position

	sprite_container.z_index = Types.ZLayers.RESOURCES

	# Pick a random launch direction
	var angle = randf_range(0, TAU)
	velocity = Vector2.RIGHT.rotated(angle) * (launch_speed * (parent_size / 100.0))
	
	# Set the final destination point for the coin
	target_position = start_position + velocity

func _process(delta):
	if moving:
		elapsed_time += delta
		var t = min(elapsed_time / lifetime, 1.0) # Clamp between 0 and 1
		
		# Ease-out curve (quadratic), makes it slow down smoothly
		t = 1 - pow(1 - t, 2)
		
		# Interpolate the main movement from start to target
		var new_position = start_position.lerp(target_position, t)
		
		# Create an arc effect: raise Y at the midpoint, then bring it back down
		new_position.y -= sin(t * PI) * arc_height # Peaks at t = 0.5
		position = new_position
		
		# Stop motion when animation ends
		if t >= 1.0:
			moving = false
			set_process(false) # Stop further movement updates

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if not moving and not collected:
		collected = true
		# Define the player ID (for example, 1 for player 1, 2 for player 2)
		var player_id = 1 # Change this to the actual player ID as needed
		
		# Add the specified resource type to the player's resources
		Global.add_resource(player_id, resource_type, num_resources)
		Inventory.add_item_to_inventory(resource_type, num_resources)
		
		# Play audio and animation
		var rand = randf_range(0.5, 1.0)
		audio_stream_player_2d.pitch_scale = rand
		audio_stream_player_2d.play()
		animation_player.play('pickup')
