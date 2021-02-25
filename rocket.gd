extends RigidBody2D

var rng = RandomNumberGenerator.new()

var thrust_time:float = 0.2
var thrust_index:int = 0
var debug:bool = false setget set_debug

var genes:Genes

var delta_time:float = thrust_time
var nearest_path_point:Vector2

func set_debug(new_value):
	debug = new_value
	update()


func update_visuals():
	$Name.text = genes.first_name + "\n" + genes.family_name
	$SpriteInner.modulate = Lineage.get_family_colors(genes.family_name)
	$SpriteQuad.modulate = Color.blue if genes.sex == 0 else Color.pink


func _physics_process(delta):
	
	var curve:Curve2D = get_parent().get_parent().curve
	nearest_path_point = curve.get_closest_point(position)
	update()
	
	delta_time += delta
	
	if delta_time >= thrust_time:
		delta_time -= thrust_time
		update_genetic_score()
		thrust()


func update_genetic_score():
	var new_genetic_score = get_parent().get_genetic_score(position)
	if new_genetic_score > genes.score:
		genes.score = new_genetic_score
	$Score.visible = debug
	$Name.visible = debug
	$Score.text = str(stepify(genes.score,0.01))
	get_parent().get_parent().get_node("UI").update_labels(genes)


func thrust():
	
	if thrust_index == genes.thrust_sequence.size():
		thrust_index = 0
	
	#print("thrust: ",thrust_sequence[0] )
	
	#apply_impulse(Vector2.ZERO,genes.thrust_sequence[thrust_index] * 32)
	applied_force = genes.thrust_sequence[thrust_index] * 32 * 4
	thrust_index += 1
	
	update()


func _draw():
	if not debug:
		return
	#draw_line(Vector2.ZERO,-applied_force.normalized() * 32,Color.red,5.0)
	draw_line(Vector2.ZERO,nearest_path_point-position,Color.green,3.0,true)
	draw_circle(nearest_path_point-position,10.0,Color.green)


func _on_Rocket_body_entered(body):
	
	if "Goal" in body.name:
		position = body.position
		die()


func die():
	update_genetic_score()
	get_parent().add_to_gene_pool(genes)
	queue_free()




