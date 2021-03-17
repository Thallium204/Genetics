extends RigidBody2D

const THRUST = 200.0
const TORQUE = 5.0
const THRUST_MULTIPLIER = 3.0
const REVERSE_MULTIPLIER = 0.6
const FUEL_MAX = 200.0
var fuel = FUEL_MAX
const FUEL_COST = 0.1

var input_keys = []

var view_angle = 0.0
var field_of_view = 90
var view_distance = 100.0
var view_segments = 10

var ray_dir_vectors = PoolVector2Array()
var ray_hit_vectors = PoolVector2Array()
var ray_colors = PoolColorArray()

var network:Network

func _ready():
	$Sprite/Sight.value = field_of_view
	$UI/FuelBar.max_value = FUEL_MAX
	update_visuals()
	$UI/FuelBar.step = 0.1
	generate_ray_directions()
	network = Network.new( ray_colors.size() , 10 , 4 )
	

func generate_ray_directions():
	
	ray_dir_vectors = PoolVector2Array()
	ray_hit_vectors = PoolVector2Array()
	ray_colors = PoolColorArray()
	
	var rad_per_segment = deg2rad(field_of_view) / float(view_segments)
	for seg_index in view_segments:
		var angle = (seg_index + 0.5) * rad_per_segment + deg2rad(field_of_view)/2
		var vector = Vector2( sin(angle) , cos(angle) )
		ray_dir_vectors.append(vector)
		ray_hit_vectors.append(Vector2.ZERO)
		ray_colors.append(Color.black)


func update_visuals():
	$UI/FuelBar.value = fuel

func blink():
	
	for index in ray_dir_vectors.size():
		if not use_fuel(0.5):
			ray_colors[index] = Color(1,1,1,0)
			continue
		var result = cast_ray(ray_dir_vectors[index])
		if result:
			ray_colors[index] = Color.white
			ray_hit_vectors[index] = (result.position - position).rotated(-rotation)
		else:
			ray_colors[index] = Color.black
			ray_hit_vectors[index] = Vector2()
	
	if use_fuel(10.0):
		network.set_input(ray_colors)
		think()


func think():
	var result = network.feed_forward()
	
	if result[0] >= 0.5:
		add_key(KEY_UP)
	else:
		remove_key(KEY_UP)
	
	if result[1] >= 0.5:
		add_key(KEY_DOWN)
	else:
		remove_key(KEY_DOWN)
	
	if result[2] >= 0.5:
		add_key(KEY_LEFT)
	else:
		remove_key(KEY_LEFT)
	
	if result[3] >= 0.5:
		add_key(KEY_RIGHT)
	else:
		remove_key(KEY_RIGHT)
	
	print(result)


func cast_ray(direction:Vector2):
	#print("casting in: ",direction)
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var ray_vector = (direction * view_distance).rotated(rotation)
	var result = space_state.intersect_ray(position, position + ray_vector)
	return result


func _draw():
	
	for index in ray_dir_vectors.size():
		var draw_vector
		var time = $Timer.time_left / $Timer.wait_time
		var color = ray_colors[index]
		color.a = clamp(time,0,color.a)
		if ray_hit_vectors[index] == Vector2():
			draw_vector = ray_dir_vectors[index] * view_distance
		else:
			draw_vector = ray_hit_vectors[index]
		draw_line(Vector2(), draw_vector, color, 1.0)


func _physics_process(delta):
	update_forces(delta)
	$UI.rotation = -rotation
	update()

func _on_Timer_timeout():
	blink()


func _unhandled_key_input(event):
	
	if event.pressed:
		add_key(event.scancode)
	else:
		remove_key(event.scancode)

func update_forces(delta):
	
	$Particles.initial_velocity = 100
	$Particles.emitting = false
	$ParticlesTorque.emitting = false
	
	if fuel <= 0:
		return
	#angular_velocity /= 1.1
	var thrust_multiplier = 1.0
	
	if KEY_RIGHT in input_keys:
		if use_fuel():
			angular_velocity += TORQUE * delta
			$ParticlesTorque.direction.y = -1
			$ParticlesTorque.emitting = true
	
	if KEY_LEFT in input_keys:
		if use_fuel():
			angular_velocity -= TORQUE * delta
			$ParticlesTorque.direction.y = +1
			$ParticlesTorque.emitting = true
	
	
	if KEY_SHIFT in input_keys:
		thrust_multiplier = THRUST_MULTIPLIER
		#$Particles.color = Color(1,0,0,0.5)
		$Particles.initial_velocity = 300
	
	if KEY_UP in input_keys:
		if use_fuel(thrust_multiplier):
			$Particles.emitting = true
			linear_velocity += Vector2(+1.0,0).rotated(rotation) * THRUST * thrust_multiplier * delta
	
	if KEY_DOWN in input_keys:
		if use_fuel(REVERSE_MULTIPLIER):
			linear_velocity += Vector2(-1.0,0).rotated(rotation) * THRUST * REVERSE_MULTIPLIER * delta
	
	update_visuals()

func add_key(scancode):
	if not scancode in input_keys:
		input_keys.append(scancode)

func remove_key(scancode):
	if scancode in input_keys:
		input_keys.erase(scancode)


func use_fuel(multiplier = 1.0) -> bool:
	if fuel - (FUEL_COST * multiplier) < 0:
		return false
	fuel = fuel - (FUEL_COST * multiplier)
	return true




















