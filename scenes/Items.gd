# Items
extends Label

var item_count = 0

func _ready():
	update_text()

func _on_Player_got_item(item_name):
	print("got item ", item_name)
	item_count += 1
	update_text()
	

func update_text():
	self.text = str(item_count)
