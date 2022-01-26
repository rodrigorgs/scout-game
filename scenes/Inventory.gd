extends HBoxContainer

var tilemap: TileMap

#func _ready():
#	_on_Player_inventory_changed([], 4, 0.0)

func _on_Player_inventory_changed(item_names: Array, capacity, money, current_tool):
	$Money.text = str(int(money))

	update_tool(current_tool)
	
	for i in range(capacity):
		var item_name = null
		if i < len(item_names): 
			item_name = item_names[i]
		
		var new_texture = null
		if item_name == null:
			# No item
			var img = Image.new()
			img.load("res://images/slot.png")
			new_texture = ImageTexture.new()
			new_texture.create_from_image(img)
		else:
			var path = 'res://images/' + item_name + '.png'
			print('trying path ', path)
			if load(path) != null:
				# Item that exists as an image
				var img = Image.new()
				img.load(path)
				new_texture = ImageTexture.new()
				new_texture.create_from_image(img)
				print('ok')
			else:
				# Item that exists in the tileset
				var tile_id = tilemap.tile_set.find_tile_by_name(item_name)	
				var texture = tilemap.tile_set.tile_get_texture(tile_id)
				var region = tilemap.tile_set.tile_get_region(tile_id)
				new_texture = get_cropped_texture(texture, region)
			
		var node: TextureRect = get_node("Item" + str(i))
		node.texture = new_texture

func update_tool(current_tool):
	var img = load(current_tool['image'])
	$CurrentTool.texture = img

func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture
