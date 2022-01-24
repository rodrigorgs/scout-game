extends Node2D

onready var items = get_node("TmForeground/Player/MarginContainer/VBoxContainer/HBoxContainer/Items")
onready var player = get_node("TmForeground/Player")

func _ready():
	print("Connecting item signal")
	player.connect("got_item", items, "_on_Player_got_item")
	player.tileMap = $TmForeground
	
