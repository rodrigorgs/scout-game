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
	
func _on_dynamite_exploded(dynamite: Area2D):
	print('boom!')
	$explosion_sound.play()
	
	var tilemap = $TmForeground
	var center = tilemap.world_to_map(dynamite.position)
	
	# explode tiles
	explode_position(tilemap, center.x, center.y)
	explode_position(tilemap, center.x, center.y - 1)
	explode_position(tilemap, center.x, center.y + 1)
	explode_position(tilemap, center.x - 1, center.y)
	explode_position(tilemap, center.x - 1, center.y - 1)
	explode_position(tilemap, center.x - 1, center.y + 1)
	explode_position(tilemap, center.x + 1, center.y)
	explode_position(tilemap, center.x + 1, center.y - 1)
	explode_position(tilemap, center.x + 1, center.y + 1)
	
	# explode monsters
	for body in dynamite.get_overlapping_bodies():
		if body is Monster:
			body.queue_free()
	for body in dynamite.get_overlapping_areas():
		print("overlapping")
		if body is Dynamite:
			print("dynamite")
			body.light_fire()
	
	dynamite.queue_free()
	
	
func explode_position(tilemap: TileMap, x: int, y: int) -> void:
	var tile_id = tilemap.get_cell(x, y)
	if tile_id > 0:
		var name = tilemap.tile_set.tile_get_name(tile_id)
		if name.begins_with("block-"):
			tilemap.set_cell(x, y, 0)
