extends Area2D

signal dynamite_exploded

func _ready():
	$Timer.start()

func _on_Timer_timeout():
	emit_signal("dynamite_exploded", self)
