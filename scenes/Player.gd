extends KinematicBody2D

var speed = 50  # speed in pixels/sec
var velocity = Vector2.ZERO
var direction = 'left'
var direction_vector = Vector2.LEFT
onready var sprite: AnimatedSprite = get_node("AnimatedSprite")
var firing = false
onready var raycast = get_node("RayCast2D")
onready var sensor = get_node("Sensor")
export(NodePath) var tileMap
var attack = 2
var money = 0.0

const INVENTORY_CAPACITY = 4
var items = []

signal inventory_changed

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
	if Input.is_action_just_pressed("interact"):
		if sensor_overlaps_group('sales'):
			sell_items()
	if Input.is_action_just_pressed('ui_select') and not firing:
		$attack_sound.play()
		firing = true
		sprite.play('fire-' + direction)
		if not sprite.is_connected("animation_finished", self, 'finish_fire_animation'):
			sprite.connect("animation_finished", self, 'finish_fire_animation', [CONNECT_ONESHOT])
		fire()
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed
	if velocity != Vector2.ZERO:
		direction_vector = velocity
	
	if direction == 'up':
		sensor.rotation_degrees = 180
	elif direction == 'left':
		sensor.rotation_degrees = 90
	elif direction == 'right':
		sensor.rotation_degrees = 270
	else:
		sensor.rotation_degrees = 0
	
	# Change animation
	if not firing:
		if velocity == Vector2.ZERO:
			sprite.play('idle-' + direction)
		else:
			sprite.play('walk-' + direction)
	

func sell_items():
	var total_money = 0.0
	for item_name in items:
		if Globals.item_info.has(item_name):
			total_money += Globals.item_info.get(item_name).get('value')
	items = []
	money += total_money
	if total_money > 0:
		$sell_sound.play()
	trigger_inventory_changed()

func fire_tilemaps():
	var tilemap: TileMap = tileMap
	var player_tile_pos = tilemap.world_to_map(position)
	var normal = direction_vector.rotated(PI/2).normalized()
	var direction_unit = direction_vector.normalized()
	var neighbor_pos = [
		player_tile_pos + direction_unit,
		player_tile_pos + direction_unit + normal,
		player_tile_pos + direction_unit - normal]
	
	var min_distance = 9999999
	var index_min_distance = -1
	for index in range(3):
		var neighbor = neighbor_pos[index]
		var tile_id = tilemap.get_cellv(neighbor)
		if tile_id > 0:
			var tile_name = tilemap.tile_set.tile_get_name(tile_id)
			if tile_name.begins_with('block-'):
				var dist = tilemap.map_to_world(neighbor).distance_squared_to(position)
				if dist < min_distance:
					min_distance = dist
					index_min_distance = index
	
	if index_min_distance > -1:
		hit_tile_at(neighbor_pos[index_min_distance])

func sensor_overlaps_group(group_name):
	var bodies = sensor.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group_name):
			return true
	return false

func fire_nodes():
	var bodies = sensor.get_overlapping_bodies()
	for body in bodies:
		print('fire at ', body)
		if body is Monster:
			var monster: Monster = body
			monster.get_damage(attack)

func fire():
	fire_tilemaps()
	fire_nodes()
		
func hit_tile_at(pos):
	var tile_id = tileMap.get_cellv(pos)
	if tile_id > 0:
		var tile_name: String = tileMap.tile_set.tile_get_name(tile_id)
		if len(tile_name) > 0:
			var digit = tile_name.substr(len(tile_name) -1, 1)
			if digit.is_valid_integer():
				var next_digit = int(digit) - 1
				var next_tile_id = 0
				if next_digit != 0:
					var next_tile_name = tile_name.substr(0, len(tile_name) - 1) + str(next_digit)
					print('next: ', next_tile_name)
					next_tile_id = (tileMap as TileMap).tile_set.find_tile_by_name(next_tile_name)
				
				print('next id: ', next_tile_id)
				tileMap.set_cellv(pos, next_tile_id)
#				$break_sound.play()
			else:
				tileMap.set_cellv(pos, 0)
#				$break_sound.play()

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
			collide_with_tilemap(collision)

func get_item(item_name):
	print("Trying to get item ", item_name)
	if items.size() < INVENTORY_CAPACITY:
		items.append(item_name)
		trigger_inventory_changed()
		return true
	else:
		return false

func trigger_inventory_changed():
	emit_signal("inventory_changed", items, INVENTORY_CAPACITY, money)

func collide_with_tilemap(collision):
	var tile_pos = collision.collider.world_to_map(position)
	tile_pos -= collision.normal
	var tile_id = collision.collider.get_cellv(tile_pos)
	if tile_id > 0:
		var tile_name: String = collision.collider.tile_set.tile_get_name(tile_id)
		if tile_name.begins_with('item-'):
			if get_item(tile_name):
				collision.collider.set_cellv(tile_pos, 0)
				$pickup_sound.play()
			
		elif tile_name == 'water':
			if not $splash_sound.playing:
				$splash_sound.play()
	
