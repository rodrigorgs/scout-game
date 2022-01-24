extends Node2D

onready var items = get_node("tm-foreground/Player/MarginContainer/VBoxContainer/HBoxContainer/Items")
onready var player = get_node("tm-foreground/Player")

func _ready():
	print("Connecting item signal")
	player.connect("got_item", items, "_on_Player_got_item")
	
