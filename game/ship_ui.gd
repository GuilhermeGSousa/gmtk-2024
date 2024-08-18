extends CanvasLayer


func _on_spaceship_entered() -> void:
	visible = true

func _on_spaceship_exited() -> void:
	visible = false
