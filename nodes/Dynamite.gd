extends Area2D
class_name Dynamite

signal dynamite_exploded

func light_fire():
	if $Timer.is_stopped():
		$Timer.start()

func _on_Timer_timeout():
	emit_signal("dynamite_exploded", self)
