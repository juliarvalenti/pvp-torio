extends Control

# @onready var p1_gold_label = $CanvasLayer/P1_GoldLabel
# @onready var p1_iron_label = $CanvasLayer/P1_IronLabel
# @onready var p1_wood_label = $CanvasLayer/P1_WoodLabel
# @onready var p1_stone_label = $CanvasLayer/P1_StoneLabel

@onready var gold_label = $CanvasLayer/ResourcesContainer/GoldResource/Label
@onready var iron_label = $CanvasLayer/ResourcesContainer/IronResource/Label
@onready var wood_label = $CanvasLayer/ResourcesContainer/WoodResource/Label
@onready var stone_label = $CanvasLayer/ResourcesContainer/StoneResource/Label

func _ready():
	# Update labels on start
	update_resource_labels()
	
	# Optionally, refresh every 0.5 seconds
	$Timer.timeout.connect(update_resource_labels)
	$Timer.start(0.5) # Adjust refresh rate as needed

func update_resource_labels():
	# Get resource values from Global
	gold_label.text = str(Global.get_resource(1, Global.ResourceType.GOLD))
	iron_label.text = str(Global.get_resource(1, Global.ResourceType.IRON))
	wood_label.text = str(Global.get_resource(1, Global.ResourceType.WOOD))
	stone_label.text = str(Global.get_resource(1, Global.ResourceType.STONE))
#
	#p2_gold_label.text = "Gold: " + str(Global.get_resource(2, Global.ResourceType.GOLD))
	#p2_iron_label.text = "Iron: " + str(Global.get_resource(2, Global.ResourceType.IRON))
	#p2_wood_label.text = "Wood: " + str(Global.get_resource(2, Global.ResourceType.WOOD))
	#p2_stone_label.text = "Stone: " + str(Global.get_resource(2, Global.ResourceType.STONE))
