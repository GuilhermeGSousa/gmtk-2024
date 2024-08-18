class_name Spaceship extends RigidBody2D

@export var rotation_speed = 50.0
@export var thrust = 30.0

@export var trajectory : Line2D
@export var trajectory_time_delta : float = 1.
@export var trajectory_time_horizon : float = 100
@export var thrust_shake = 10
@export var kill_speed = 100

@export var can_control : bool = true

var current_astronaut : Astronaut

var _is_dead = false

signal on_ship_entered
signal on_ship_exited

func _ready() -> void:
	can_control = false
	$EngineVFX.emitting = false
	linear_velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not can_control:
		return
	
	var rotation_input = Input.get_axis("move_left", "move_right")
	var is_thrusting = Input.is_action_pressed("jump")
	angular_velocity = deg_to_rad(rotation_speed) * rotation_input
	
	$EngineVFX.emitting = is_thrusting
	
	if Input.is_action_just_pressed("jump"):
		$ThrustSFX.play()
	
	if Input.is_action_just_released("jump"):
		$ThrustSFX.stop()
	
	if is_thrusting:
		CameraShakeManager.on_trauma.emit(thrust_shake)
		
	
	var current_thrust = Vector2.ZERO if not is_thrusting else transform.basis_xform(Vector2.UP) * thrust
	apply_central_force(current_thrust)
	
	if linear_velocity.length() > 1.:
		_update_trajectory()
	else:
		trajectory.clear_points()
		
	if current_astronaut:
		_update_astronaut_position()

func _process(_delta: float) -> void:
	$FrontShip.material.set_shader_parameter(
		"gradient_direction", 
		transform.basis_xform_inv(linear_velocity.normalized()))
		
	var speed = linear_velocity.length()
	var force = PlanetManager.get_force_at(global_position, mass)
	
	var thresh = 0.5
	if speed > kill_speed * thresh:
		$FrontShip.material.set_shader_parameter("gradient_scale", 
		clampf(speed * 1 /((1 - thresh) * kill_speed) + (1 - 1/(1 - thresh)), 0., 1.) 
		* 4.0)
	else:
		$FrontShip.material.set_shader_parameter("gradient_scale", 0.0)

func _update_trajectory():
	trajectory.clear_points()
	var t = 0
	var current_position = global_position
	var current_velocity = linear_velocity
	var dt = trajectory_time_delta
	trajectory.add_point(current_position)
	
	while t < trajectory_time_horizon:
		var planet_gravity = PlanetManager.get_force_at(current_position, mass)
		current_velocity += (planet_gravity) * dt * 1.0 / mass
		current_position += current_velocity * dt
		trajectory.add_point(current_position)
		t += dt

func _update_astronaut_position():
	if not current_astronaut:
		return
		
	current_astronaut.global_position = $PlayerSeat.global_position
	current_astronaut.global_rotation = $PlayerSeat.global_rotation

func _on_enter_ship(interactor: Interactor) -> void:
	var astronaut = interactor.get_parent() as Astronaut
	
	if astronaut.current_planets.is_empty():
		return
		
	if astronaut.can_control:
		# We are entering
		astronaut.z_index = 0
		current_astronaut = astronaut
		current_astronaut.can_control = false
		can_control = true
		on_ship_entered.emit()
	else:
		# We are exiting
		astronaut.z_index = 1
		trajectory.clear_points()
		current_astronaut = null
		astronaut.can_control = true
		can_control = false
		astronaut.linear_velocity = linear_velocity
		on_ship_exited.emit()
	
func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > kill_speed:
		_on_death()

func _on_death():
	if _is_dead:
		return
	
	_is_dead = true
	can_control = false
	var tween = create_tween()
	tween.tween_callback(
		func() : 
			CameraShakeManager.on_trauma.emit(thrust_shake)
			$ExplosionSFX.play()
			$DeathExplosion.emitting = true
			$ThrustSFX.stop()
			trajectory.clear_points()
	)
	tween.tween_interval(5.0)
	tween.tween_callback(
		func():
			GameManager.on_death()
	)
	
