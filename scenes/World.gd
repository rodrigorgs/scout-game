extends Node2D

onready var player = get_node("Player")
onready var inventory = get_node("UI/MarginContainer/VBoxContainer/Inventory")
onready var npcs = get_node("NPCs")
onready var main_portal = npcs.get_node("PortalMain")

func _ready():
	print("Connecting item signal")
	player.connect("inventory_changed", inventory, "_on_Player_inventory_changed")
	player.tileMap = $TmForeground
	inventory.tilemap = $TmForeground
	
	main_portal.visible = false
	
	player.trigger_inventory_changed()
	
	show_prices()

func show_prices():
	var tool_names = Globals.tool_info.keys()
	for tool_name in tool_names:
		var node = npcs.get_node(tool_name)
		if node != null:
			node.text_right = "$" + str(Globals.tool_info[tool_name]['cost'])
	
	
	
