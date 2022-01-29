extends KinematicBody2D

var speed = 75  # speed in pixels/sec
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
var current_tool = Globals.tool_info['Hands']
var world

const INVENTORY_CAPACITY = 4
var items = []

signal inventory_changed

func _ready():
	world = get_parent()

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
	if Input.is_action_just_pressed("throw"):
		var dynamite = preload("res://nodes/Dynamite.tscn").instance()
		world.add_child(dynamite)
		dynamite.position = position
		var tween = Tween.new()
		dynamite.add_child(tween)
		tween.interpolate_property(dynamite, "position",
			position, position + direction_vector * 32, 1,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
		dynamite.connect("dynamite_exploded", world, "_on_dynamite_exploded")
		tween.start()
	if Input.is_action_just_pressed("interact"):
		if body_with_group_on_sensor('sales'):
			sell_items()
		elif body_with_group_on_sensor('portal'):
			teleport()
		elif body_with_group_on_sensor('tool'):
			try_to_buy_tool()
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
		direction_vector = velocity.normalized()
	
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

func try_to_buy_tool():
	var tool: KinematicBody2D = body_with_group_on_sensor('tool')
	var tool_name = tool.name
	var tool_info = Globals.tool_info[tool_name]
	var cost = Globals.tool_info[tool_name]['cost']
	if money >= cost:
		money -= cost
		# Replace only with stronger tools
		if tool_info['strength'] >= current_tool['strength']:
			current_tool = tool_info
		trigger_inventory_changed()
		if not Engine.is_editor_hint():
			tool.queue_free()
	
func teleport():
	var portal_main: KinematicBody2D = get_tree().get_nodes_in_group('portal-main')[0]
	var portal: KinematicBody2D = body_with_group_on_sensor('portal')
	var currents = get_tree().get_nodes_in_group('portal-current')
	
	if portal == portal_main:	
		if len(currents) != 0:
			var current = currents[0]
			teleport_to_node(current)
	else:
		portal_main.visible = true
		if not portal.is_in_group('portal-current'):
			for current in currents:
				current.remove_from_group('portal-current')
			portal.add_to_group('portal-current')
		
		teleport_to_node(portal_main)
		
func teleport_to_node(node: Node2D):
	position = node.position + Vector2(0, 16)
	
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
		if tile_id <= 0:
			continue
		var tile_name = tilemap.tile_set.tile_get_name(tile_id)
		if not tile_name.begins_with('block-'):
			continue
		var min_strength = Globals.block_info[tile_name]['min_strength']
		if min_strength > current_tool['strength']:
			continue
		var dist = tilemap.map_to_world(neighbor).distance_squared_to(position)
		if dist < min_distance:
			min_distance = dist
			index_min_distance = index
	
	if index_min_distance > -1:
		hit_tile_at(neighbor_pos[index_min_distance])

func body_with_group_on_sensor(group_name):
	var bodies = sensor.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(group_name):
			return body
	return null

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
	
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision and collision.collider is TileMap:
#			collide_with_tilemap(collision)

func trigger_inventory_changed():
	emit_signal("inventory_changed", items, INVENTORY_CAPACITY, money, current_tool)

func _on_item_entered(item):
	print('entered item ', item.item_name)
	if items.size() < INVENTORY_CAPACITY:
		$pickup_sound.play()
		if not Engine.editor_hint:
			item.queue_free()
		items.append(item.item_name)
		trigger_inventory_changed()
		return true
	else:
		return false


#func collide_with_tilemap(collision):
#	var tile_pos = collision.collider.world_to_map(position)
#	tile_pos -= collision.normal
#	var tile_id = collision.collider.get_cellv(tile_pos)
#	if tile_id > 0:
#		var tile_name: String = collision.collider.tile_set.tile_get_name(tile_id)
#		if tile_name == 'water':
#			if not $splash_sound.playing:
#				$splash_sound.play()
	
