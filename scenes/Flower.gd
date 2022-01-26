tool
extends Area2D
class_name Item

export(Texture) var texture: Texture setget texture_set
var item_name setget ,get_item_name

func texture_set(t: Texture):
	texture = t
	if $Sprite != null:
		$Sprite.texture = texture

func get_item_name():
	if texture == null:
		return ''
	else:
		var path = texture.resource_path
		var idx_slash = path.find_last('/')
		var idx_extension = path.find_last('.')
		return path.substr(idx_slash + 1, idx_extension - idx_slash - 1)
	
func _on_Item_body_entered(body):
	if body.has_method('_on_item_entered'):
		body._on_item_entered(self)

