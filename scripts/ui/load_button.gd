extends Button

func _ready():
	disabled = not SaveManager.has_save_file()
	SaveManager.on_game_saved.connect(_on_game_saved)
	
func _pressed():
	SaveManager.load_game()
	
func _on_game_saved():
	disabled = false
