extends KinematicBody2D

var speed = 50  # speed in pixels/sec
var velocity = Vector2.ZERO
var direction = 'left'
var direction_vector = Vector2.LEFT
onready var sprite: AnimatedSprite = get_node("AnimatedSprite")
var firing = false
onready var raycast = get_node("RayCast2D")

signal got_item

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
		if not sprite.is_connected("animation_finished", self, 'finish_fire_animation'):
			sprite.connect("animation_finished", self, 'finish_fire_animation', [CONNECT_ONESHOT])
		fire()
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	if velocity != Vector2.ZERO:
		direction_vector = velocity
	
	# Change animation
	if not firing:
		if velocity == Vector2.ZERO:
			sprite.play('idle-' + direction)
		else:
			sprite.play('walk-' + direction)
	

func fire():
	raycast.cast_to = direction_vector * 0.7
	print('fire', raycast.cast_to)
	if raycast.is_colliding():
		print('is colliding')
		if raycast.get_collider() is TileMap:
			print('is tilemap')
			var tilemap = raycast.get_collider()
			var tile_pos = tilemap.world_to_map(position)
			tile_pos -= raycast.get_collision_normal()
			print('tile pos ', tile_pos)
			var tile_id = tilemap.get_cellv(tile_pos)
			if tile_id > 0:
				var tile_name = tilemap.tile_set.tile_get_name(tile_id)
				if not tile_name.begins_with('item-'):
					print('tilename', tile_name)
					tilemap.set_cellv(tile_pos, 0)
					$break_sound.play()

func finish_fire_animation(_x):
	firing = false
	sprite.play('idle-' + direction)

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		# Confirm the colliding body is a TileMap
		if collision and collision.collider is TileMap:
			var tile_pos = collision.collider.world_to_map(position)
			tile_pos -= collision.normal
			var tile_id = collision.collider.get_cellv(tile_pos)
			if tile_id > 0:
				var tile_name: String = collision.collider.tile_set.tile_get_name(tile_id)
				if tile_name.begins_with('item-'):
					collision.collider.set_cellv(tile_pos, 0)
					emit_signal("got_item", tile_name)
					$pickup_sound.play()

