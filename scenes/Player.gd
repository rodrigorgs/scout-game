extends KinematicBody2D

var speed = 40  # speed in pixels/sec
var velocity = Vector2.ZERO
var direction = 'left'
onready var sprite: AnimatedSprite = get_node("AnimatedSprite")
var firing = false
var just_fired = false

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
		just_fired = true
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

func _physics_process(delta):
	get_input()
	var collision = move_and_collide(velocity * delta)

	# Confirm the colliding body is a TileMap
	if collision and collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map(position)
		tile_pos -= collision.normal
		var tile_id = collision.collider.get_cellv(tile_pos)
		var tile_name = collision.collider.tile_set.tile_get_name(tile_id)
		print('collided with' + tile_name)
		
		if tile_name == 'item':
			collision.collider.set_cellv(tile_pos, 0)
		elif just_fired:
			collision.collider.set_cellv(tile_pos, 0)
		
	
	just_fired = false

