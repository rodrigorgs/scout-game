tool
extends KinematicBody2D

export(Texture) var texture setget texture_set
export(String) var text_left setget text_left_set
export(String) var text_right setget text_right_set

func text_left_set(t):
	text_left = t
	if $LabelLeft != null:
		$LabelLeft.text = t

func text_right_set(t):
	text_right = t
	if $LabelRight != null:
		$LabelRight.text = t

func texture_set(t):
	texture = t
	if $Sprite != null:
		$Sprite.texture = texture
