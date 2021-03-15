extends RigidBody2D

const THRUST = 5000.0
const TORQUE = 5.0
const THRUST_MULTIPLIER = 3.0
const FUEL_MAX = 100.0
var fuel = FUEL_MAX setget set_fuel

var input_keys = []

var view_angle = 0.0
var ray_directions = {}
var field_of_view = 90
var view_distance = 100.0
var view_segments = 10

func set_fuel(value):
	fuel = clamp(value,0,FUEL_MAX)


func _ready():
	$Sprite/Sight.value = field_of_view
	$FuelBar.max_value = FUEL_MAX
	update_visuals()
	$FuelBar.step = 0.1
	generate_ray_directions()

func generate_ray_directions():
	ray_directions = {}
	var rad_per_segment = deg2rad(field_of_view) / float(view_segments)
	for seg_index in view_segments:
		var angle = (seg_index + 0.5) * rad_per_segment + deg2rad(field_of_view)/2
		var vector = Vector2( sin(angle) , cos(angle) )
		ray_directions[vector] = {"color":Color.green, "hit_pos":Vector2()}


func update_visuals():
	$FuelBar.value = fuel

func blink():
	for direction in ray_directions:
		var data = ray_directions[direction]
		var result = cast_ray(direction)
		if result:
			data.color = Color.red
			data.hit_pos = (result.position - position).rotated(-rotation)
		else:
			data.color = Color.green
			data.hit_pos = Vector2()

func cast_ray(direction:Vector2):
	#print("casting in: ",direction)
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var ray_vector = (direction * view_distance).rotated(rotation)
	var result = space_state.intersect_ray(position, position + ray_vector)
	return result


func _draw():
	
	for direction in ray_directions:
		var data = ray_directions[direction]
		var draw_vector
		var time = $Timer.time_left / $Timer.wait_time
		var color
		if data.color == Color.green:
			color = Color(0,time,0)
		else:
			color = Color(time,0,0)
		if data.hit_pos == Vector2():
			draw_vector = direction * view_distance
		else:
			draw_vector = data.hit_pos
		draw_line(Vector2(), draw_vector, color, 1.0)


func _physics_process(delta):
	update_forces(delta)
	update()

func _on_Timer_timeout():
	blink()


func _unhandled_key_input(event):
	
	if event.pressed:
		add_key(event.scancode)
	else:
		remove_key(event.scancode)

func update_forces(delta):
	
	applied_force = Vector2()
	$Particles.initial_velocity = 100
	$Particles.emitting = false
	
	if fuel <= 0:
		return
	#angular_velocity /= 1.1
	var thrust_multiplier = 1.0
	
	if KEY_RIGHT in input_keys:
		angular_velocity += TORQUE * delta
	
	if KEY_LEFT in input_keys:
		angular_velocity -= TORQUE * delta
	
	
	if KEY_SHIFT in input_keys:
		thrust_multiplier = THRUST_MULTIPLIER
		#$Particles.color = Color(1,0,0,0.5)
		$Particles.initial_velocity = 300
	
	if KEY_UP in input_keys:
		$Particles.emitting = true
		applied_force += Vector2(+1.0,0).rotated(rotation) * THRUST * thrust_multiplier * delta
		self.fuel -= 0.5 * thrust_multiplier
	
	if KEY_DOWN in input_keys:
		applied_force += Vector2(-1.0,0).rotated(rotation) * THRUST * thrust_multiplier * delta
	
	update_visuals()

func add_key(scancode):
	if not scancode in input_keys:
		input_keys.append(scancode)

func remove_key(scancode):
	if scancode in input_keys:
		input_keys.erase(scancode)



