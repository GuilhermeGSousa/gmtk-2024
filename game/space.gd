extends Node

@export_flags_2d_render var mask

func _ready() -> void:
	get_viewport().set_canvas_cull_mask_bit(mask, true)
