class_name GravityField extends Area2D

@export var planet_gravity_acceleration = 10

var affected_bodies : Array[PhysicsBody2D]
var radius = 0.

func _enter_tree() -> void:
	PlanetManager.register_planet(self)
	
func _exit_tree() -> void:
	PlanetManager.unregister_planet(self)


func _ready() -> void:
	var circle_shape = $CollisionShape2D.shape as CircleShape2D
	radius = circle_shape.radius
	
func _physics_process(delta: float) -> void:
	for body in affected_bodies:
		if body is RigidBody2D:
			body.apply_central_force(get_force_at(body.global_position, body.mass))

func _on_gravity_field_body_entered(body: Node2D) -> void:
	if body is PhysicsBody2D:
		affected_bodies.append(body)

func _on_gravity_field_body_exited(body: Node2D) -> void:
	if body is PhysicsBody2D:
		affected_bodies.erase(body)

func get_force_at(pos : Vector2, body_mass : float) -> Vector2:
	var distance_sqr = global_position.distance_squared_to(pos)
	var force_dir = (pos - global_position).normalized()
	return -force_dir * planet_gravity_acceleration * body_mass
