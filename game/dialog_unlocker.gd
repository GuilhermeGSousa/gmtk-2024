extends Node

@export var next_dialog: DialogInteractable

func _on_dialog_interacted(interactor: Interactor) -> void:
	if not next_dialog: return
	next_dialog.visible = true
	next_dialog.monitoring = true
	next_dialog.monitorable = true
