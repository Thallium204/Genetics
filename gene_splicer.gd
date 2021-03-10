extends TileMap

signal begin_simulation
signal generation_spawned
signal end_simulation
signal toggle_debug(state)

var rng = RandomNumberGenerator.new()
var rocket_load = preload("res://Rocket.tscn")

var simul_time:float = Genetics.SIMUL_TIME # seconds

onready var _WORLD_BORDERS = get_tree().get_root().size

var path_max_length = 0.0
var debug:bool = false setget set_debug
var goal_positions:PoolVector2Array


func set_debug(new_value):
	debug = new_value


func _ready():
	var _err
	rng.randomize()
	fill_floor()
	get_parent().update_path()
	_err = connect("toggle_debug",self,"set_debug")
	_err = connect("begin_simulation",self,"spawn_rocket_generation")
	_err = connect("generation_spawned",get_parent().get_node("UI"),"display_info")


func fill_floor():
	
	var wall_positions = get_used_cells_by_id(1)
	var start = wall_positions[0]
	var end = wall_positions[0]
	
	for vector in wall_positions:
		if vector.x < start.x:
			start.x = vector.x
		elif vector.x > end.x:
			end.x = vector.x
		if vector.y < start.y:
			start.y = vector.y
		elif vector.y > end.y:
			end.y = vector.y
	
	for x in range(start.x,end.x):
		for y in range(start.y,end.y):
			if Vector2(x,y) in wall_positions:
				continue
			set_cell(x,y,2)
	
	update_dirty_quadrants()


func add_goal(goal_position):
	goal_positions.append(goal_position)


func get_genetic_score(rocket_position):
	
	# closeness_score: 1 ~ on target | 0 ~ too far away
	var closeness_score = 1 - get_parent().get_length_to_goal(rocket_position)/path_max_length
	# timing_score: 1 ~ instant goal | 0 ~ didn't make it
	var timing_score = 1 - simul_time / Genetics.SIMUL_TIME
	# genetic_score: 1 ~ best | 0 ~ worst
	var _genetic_score = (pow(2,closeness_score) - 1 + pow(2,timing_score) - 1) / 2.0
	#print(closeness_score," ",timing_score," ",genetic_score)
	return 3 * closeness_score + (timing_score - 1) * 0


func spawn_rocket_generation():
	
	GenePool.print_gene_pool()
	#print("\n")
	var relationships = GenePool.get_relationships()
	for relation_id in relationships:
		
		var childrens_genes = GenePool.create_childrens_genes()
		for genes in childrens_genes:
			spawn_rocket(genes)
		
		if get_tree().get_nodes_in_group("rocket").size() >= Genetics.ROCKETS:
			break
	
	var new_rockets_needed = Genetics.ROCKETS - get_tree().get_nodes_in_group("rocket").size()
	for new_rocket_id in max(0,new_rockets_needed):
		spawn_rocket(GenePool.create_child_from_random())
	
	GenePool.empty_pool()
	
	emit_signal("generation_spawned")


func spawn_rocket(genes:Genes):
	var _err
	var rocket = rocket_load.instance()
	rocket.position = $Spawn.position
	_err = connect("end_simulation",rocket,"die")
	_err = connect("toggle_debug",rocket,"set_debug")
	rocket.genes = genes
	rocket.debug = debug
	rocket.update_visuals()
	rocket.thrust_time = Genetics.SIMUL_TIME / float(Genetics.THRUSTS)
	add_child(rocket)


func get_random_entry(array:Array,remove:bool = false):
	var index = rng.randi_range(0,array.size()-1)
	var value = array[index]
	if remove:
		array.remove(index)
	return value


func _physics_process(delta):
	
	if simul_time >= Genetics.SIMUL_TIME:
		emit_signal("end_simulation")
		if get_tree().get_nodes_in_group("rocket").empty():
			simul_time -= Genetics.SIMUL_TIME
			emit_signal("begin_simulation")
	else:
		simul_time += delta
		get_node("../UI").time_slider.get_node("SimulTime").value = simul_time


func _on_Time_value_changed(value):
	Genetics.SIMUL_TIME = value



