extends RigidBody2D

var view_angle = 0.0
var ray_directions = {}
var field_of_view = 90
var view_distance = 100.0
var view_segments = 10

func _ready():
	$Sprite/Sight.value = field_of_view
	generate_ray_directions()


func generate_ray_directions():
	ray_directions = {}
	var rad_per_segment = deg2rad(field_of_view) / float(view_segments)
	for seg_index in view_segments:
		var angle = (seg_index + 0.5) * rad_per_segment + deg2rad(field_of_view)/2
		var vector = Vector2( sin(angle) , cos(angle) )
		ray_directions[vector] = {"color":Color.green, "hit_pos":Vector2()}


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
	update()


func _on_Timer_timeout():
	blink()

func _unhandled_key_input(event):
	
	if event.scancode == KEY_UP:
		if event.pressed:
			applied_force = Vector2(+1.0,0).rotated(rotation) * 50
		else:
			applied_force = Vector2(0,0)
	
	elif event.scancode == KEY_RIGHT:
		if event.pressed:
			angular_velocity = +1.0
		else:
			angular_velocity = 0.0
	
	elif event.scancode == KEY_DOWN:
		if event.pressed:
			applied_force = Vector2(-1.0,0).rotated(rotation) * 50
		else:
			applied_force = Vector2(0,0)
	
	elif event.scancode == KEY_LEFT:
		if event.pressed:
			angular_velocity = -1.0
		else:
			angular_velocity = 0.0
	
	print()
	print("applied_force = ",applied_force)
	print("angular_velocity = ",angular_velocity)
	print(rotation)
