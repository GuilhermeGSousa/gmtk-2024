extends Node

var registered_planets : Array[GravityField]

func get_force_at(position : Vector2, body_mass : float):
	var force = Vector2.ZERO
	
	for planet in registered_planets:
		var dist_sqr = position.distance_squared_to(planet.global_position)
		if dist_sqr < planet.radius * planet.radius:
			force += planet.get_force_at(position, body_mass)
			
	return force
	
func register_planet(field : GravityField):
	registered_planets.append(field)

func unregister_planet(field : GravityField):
	registered_planets.erase(field)
