class_name Astronaut extends RigidBody2D

@export var vertical_thrust = 10.
@export var horizontal_thrust = 10.
@export var max_speed = 10.
@export var can_control : bool = true :
	set(value):
		can_control = value
		$AnimationTree.active = value
@export var jetpack : CPUParticles2D

var current_planets: Array[GravityField]
signal on_planet_entered(field:GravityField)
signal on_planet_exited(field:GravityField)

func _ready() -> void:
	can_control = true

func _physics_process(delta: float) -> void:
	if not can_control:
		jetpack.emitting = false
		return
	
	var planet_gravity = PlanetManager.get_force_at(global_position, mass)
	var angle = (-planet_gravity).angle_to(Vector2.UP)
	rotation = -angle	
	
	var horizontal_input = Input.get_axis("move_left", "move_right")

	var is_thrusting = Input.is_action_pressed("jump")
	
	if is_thrusting or abs(horizontal_input) > 0.1:
		jetpack.emitting = true
		
		if not $JetSFX.playing:
			$JetSFX.play()
			
		var rot = 0
		if is_thrusting and abs(horizontal_input) < 0.1:
			rot = 0
		elif horizontal_input > 0:
			rot = deg_to_rad(40)
		else:
			rot = deg_to_rad(-20)
			
		create_tween().tween_property(jetpack, "rotation", rot, 0.5)
	else:
		jetpack.emitting = false
		$JetSFX.stop()
		
	if linear_velocity.length() > max_speed and not current_planets.is_empty() :
		linear_velocity = linear_velocity.normalized() * max_speed
	
	apply_central_force(horizontal_input * transform.basis_xform(Vector2.RIGHT) )
	apply_central_force(Vector2.ZERO if not is_thrusting else -planet_gravity.normalized() * vertical_thrust )


func _on_planet_entered(area: Area2D) -> void:
	if area is GravityField:
		current_planets.append(area)

func _on_planet_exited(area: Area2D) -> void:
	if area is GravityField:
		current_planets.erase(area)
		on_planet_exited.emit(area)

func get_horizontal_input():
	return Input.get_axis("move_left", "move_right") 
