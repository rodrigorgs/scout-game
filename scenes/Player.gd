extends KinematicBody2D

var speed = 40  # speed in pixels/sec
var velocity = Vector2.ZERO
var direction = 'left'
onready var sprite: AnimatedSprite = get_node("AnimatedSprite")
var firing = false

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		direction = 'right'
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		direction = 'left'
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
		direction = 'down'
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
		direction = 'up'
	if Input.is_action_just_pressed('ui_select') and not firing:
		firing = true
		sprite.play('fire-' + direction)
		sprite.connect("animation_finished", self, 'finish_fire_animation')
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	# Change animation
	if not firing:
		if velocity == Vector2.ZERO:
			sprite.play('idle-' + direction)
		else:
			sprite.play('walk-' + direction)
	
	
func finish_fire_animation():
	firing = false	

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
