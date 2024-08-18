extends Node

func on_death():
	SaveManager.load_game()
