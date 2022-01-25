extends KinematicBody2D
class_name Monster

export(Vector2) var velocity = Vector2.UP * 20
export(int) var health = 3
export(Texture) var texture setget texture_set

func texture_set(t):
	texture = t
	$Sprite.texture = texture

func _physics_process(delta):
	move_and_slide(velocity)
	
	if get_slide_count() > 0:
		velocity = -velocity

func get_damage(amount):
	velocity = -velocity
	health -= amount
	if health <= 0:
		queue_free()
