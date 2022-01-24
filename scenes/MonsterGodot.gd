extends KinematicBody2D
class_name Monster

export(Vector2) var velocity = Vector2.UP * 20
export(int) var health = 3

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(velocity)
	
	if get_slide_count() > 0:
		velocity = -velocity

func get_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
