class_name CameraTargetManager extends Node

@export var cam_targeter : CameraTargeter
@export var player : Astronaut
@export var spaceship : Spaceship

@export var player_zoom = 1.
@export var ship_zoom = 1.

var is_in_ship = false

func _ready() -> void:
	spaceship.on_ship_entered.connect(_on_ship_entered)
	spaceship.on_ship_exited.connect(_on_ship_exited)
	
	player.on_planet_exited.connect(_on_planet_exited)
	
	cam_targeter.targets.clear()
	
	cam_targeter.add_target(player.get_path())
	cam_targeter.max_zoom = player_zoom

func _process(delta: float) -> void:
	if not is_in_ship:
		cam_targeter.camera.rotation = player.rotation
	else:
		cam_targeter.camera.rotation = 0
func _on_ship_entered():
	is_in_ship = true
	cam_targeter.add_target(spaceship.get_path())
	
	for p in player.current_planets:
		cam_targeter.add_target(p.get_parent().get_path())
	
	cam_targeter.max_zoom = ship_zoom

func _on_ship_exited():
	is_in_ship = false
	cam_targeter.remove_target(spaceship.get_path())
	
	for p in player.current_planets:
		cam_targeter.remove_target(p.get_parent().get_path())
		
	cam_targeter.max_zoom = player_zoom

func _on_planet_exited(planet : GravityField):
	cam_targeter.remove_target(planet.get_parent().get_path())
