extends Node2D

onready var player = get_node("TmForeground/Player")
onready var inventory = get_node("TmForeground/Player/MarginContainer/VBoxContainer/Inventory")

func _ready():
	print("Connecting item signal")
	player.connect("got_item", inventory, "_on_Player_got_item")
	player.connect("inventory_changed", inventory, "_on_Player_inventory_changed")
	player.tileMap = $TmForeground
	inventory.tilemap = $TmForeground
	
