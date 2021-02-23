extends RigidBody2D

var rng = RandomNumberGenerator.new()

var thrust_time:float = 0.2
var thrust_index:int = 0

var genes = { 
			"genetic_score":0.0,
			"sex":0,
			"first_name": "FIRST",
			"family_name": "FAMILY",
			"thrust_sequence":PoolVector2Array(),
	}

var delta_time:float = thrust_time


func update_visuals(family_color):
	$Name.text = genes.first_name + "\n" + genes.family_name
	$SpriteInner.modulate = family_color
	$SpriteQuad.modulate = Color.blue if genes.sex == 0 else Color.pink


func _physics_process(delta):
	
	delta_time += delta
	
	if delta_time >= thrust_time:
		delta_time -= thrust_time
		update_genetic_score()
		thrust()


func update_genetic_score():
	var new_genetic_score = get_parent().get_genetic_score(position)
	if new_genetic_score > genes.genetic_score:
		genes.genetic_score = new_genetic_score
	$Score.text = str(stepify(genes.genetic_score,0.01))


func thrust():
	
	if thrust_index == genes.thrust_sequence.size():
		thrust_index = 0
	
	#print("thrust: ",thrust_sequence[0] )
	
	#apply_impulse(Vector2.ZERO,thrust_sequence[thrust_index] * 32)
	applied_force = genes.thrust_sequence[thrust_index] * 128
	thrust_index += 1
	
	update()


func _draw():
	return
	draw_line(Vector2.ZERO,-applied_force.normalized() * 32,Color.red,5.0)


func _on_Rocket_body_entered(body):
	
	if "Goal" in body.name:
		position = body.position
		die()


func die():
	update_genetic_score()
	get_parent().add_to_gene_pool(genes.duplicate(true))
	queue_free()




