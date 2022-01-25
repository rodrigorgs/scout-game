extends HBoxContainer

var tilemap: TileMap

func _ready():
	_on_Player_inventory_changed([], 4)

func _on_Player_inventory_changed(item_names: Array, capacity):
	for i in range(capacity):
		var item_name = null
		if i < len(item_names): 
			item_name = item_names[i]
		
		var new_texture = null
		if item_name == null:
			var img = Image.new()
			img.load("res://images/slot.png")
			#var img = preload("res://images/slot.png")
			new_texture = ImageTexture.new()
			new_texture.create_from_image(img)
		else:
			var tile_id = tilemap.tile_set.find_tile_by_name(item_name)	
			var texture = tilemap.tile_set.tile_get_texture(tile_id)
			var region = tilemap.tile_set.tile_get_region(tile_id)
			new_texture = get_cropped_texture(texture, region)
			
		var node: TextureRect = get_node("Item" + str(i))
		node.texture = new_texture

func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture
