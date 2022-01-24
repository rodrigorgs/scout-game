extends KinematicBody2D

var speed = 40  # speed in pixels/sec
var velocity = Vector2.ZERO
var direction = 'left'
onready var sprite: AnimatedSprite = get_node("AnimatedSprite")

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
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	# Change animation
	if velocity == Vector2.ZERO:
		sprite.animation = 'idle-' + direction
	else:
		sprite.animation = 'walk-' + direction
	
	

func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)
