extends StaticBody2D

@export var astronaut : Astronaut
@export var camera_targeter : CameraTargeter

func _on_tip_dialog_finished() -> void:
	$AnimationPlayer.play("showing")
	camera_targeter.remove_target(astronaut.get_path())
	camera_targeter.add_target(get_path())
	camera_targeter.max_zoom = 0.1
