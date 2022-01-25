tool
extends KinematicBody2D

export(Texture) var texture setget texture_set

func texture_set(t):
	texture = t
	$Sprite.texture = texture
