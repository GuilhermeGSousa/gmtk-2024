extends Node2D


@export var rotation_speed = 10.0


func _process(delta: float) -> void:
	rotate(deg_to_rad(rotation_speed) * delta)
