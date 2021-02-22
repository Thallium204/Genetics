extends RigidBody2D

var rng = RandomNumberGenerator.new()

var thrust_time:float = 0.5
var thrust_length:int = 100
var thrust_sequence = PoolVector2Array()

var delta_time:float = thrust_time


func _ready():
	
	rng.randomize()
	
	for thrust in thrust_length:
		var angle = rng.randf_range(0,360)
		var thrust_vector = Vector2(sin(angle),cos(angle))
		thrust_sequence.append(thrust_vector)


func _physics_process(delta):
	
	delta_time += delta
	
	if delta_time >= thrust_time:
		delta_time -= thrust_time
		
		thrust()


func thrust():
	
	if thrust_sequence.empty():
		queue_free()
		return
	
	#print("thrust: ",thrust_sequence[0] )
	
	#apply_impulse(Vector2.ZERO,thrust_sequence[0] * 32)
	applied_force = thrust_sequence[0] * 128
	thrust_sequence.remove(0)
	
	update()


func _draw():
	
	draw_line(Vector2.ZERO,applied_force.normalized() * 32,Color.red,5.0)


func _on_Rocket_body_entered(body):
	
	if "Goal" in body.name:
		
		queue_free()


func _on_Rocket_tree_exited():
	get_parent().add_genes(thrust_sequence,position)
