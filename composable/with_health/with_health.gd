extends Node

## Allows customization from the Inspector
@export var max_health: int = 100
var current_health: int

signal health_depleted # Notifies when health reaches zero

func _ready():
		current_health = max_health # Start with full health

func take_damage(amount: int):
		current_health -= amount
		print("Health remaining:", current_health)

		if current_health <= 0:
				health_depleted.emit() # Send a signal to the parent