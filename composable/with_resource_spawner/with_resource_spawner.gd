extends Node2D

# Define a list of resource types
var resource_types: Array = [
	{"name": Types.ResourceType.GOLD, "scene": preload("res://resource/gold/gold.tscn")},
	{"name": Types.ResourceType.IRON, "scene": preload("res://resource/iron/iron.tscn")},
	{"name": Types.ResourceType.WOOD, "scene": preload("res://resource/wood/wood.tscn")},
	{"name": Types.ResourceType.STONE, "scene": preload("res://resource/stone/stone.tscn")}
]

# Default resource type
@export var resource_type: Types.ResourceType = Types.ResourceType.GOLD

# Timer
@onready var timer: Timer = $Timer

# Spawn interval
@export var spawn_interval: float = 1.0 # How often to spawn resources (in seconds)

func _ready():
	timer.wait_time = spawn_interval
	timer.timeout.connect(spawn_resource)
	timer.start()

	var this_sprite = get_parent().get_node_or_null("Sprite2D")
	if this_sprite:
		this_sprite.z_index = Types.ZLayers.BUILDINGS
	
# Function to spawn a resource
func spawn_resource():
	if resource_types.size() > 0:
		var selected_resource = resource_types[resource_type]
		var resource_scene = selected_resource.scene

		if resource_scene:
			var resource = resource_scene.instantiate()
			resource.global_position = Vector2(0, 0)
			# Give it a random direction
			var angle = randf() * TAU # TAU is 2 * PI (full circle)
			var direction = Vector2(cos(angle), sin(angle))
			# Check if the resource is a RigidBody2D and apply impulse
			if resource is RigidBody2D:
				resource.apply_impulse(Vector2(), direction)
			else:
				resource.velocity = direction
			get_parent().add_child(resource)
	
func _process(_delta: float) -> void:
	pass
