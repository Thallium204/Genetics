extends TileMap

signal begin_simulation
signal generation_spawned
signal end_simulation
signal toggle_debug(state)

var rng = RandomNumberGenerator.new()
var rocket_load = preload("res://Rocket.tscn")

enum Sex{MALE,FEMALE}

var SIMUL_TIME:float = 10.0
var simul_time:float = 0.0 # seconds

onready var WORLD_BORDERS = get_tree().get_root().size

var debug:bool = false setget set_debug
var goal_positions:PoolVector2Array
var gene_pool = {"fathers":[],"mothers":[]}


func set_debug(new_value):
	debug = new_value


func _ready():
	rng.randomize()
	fill_floor()
	get_parent().update_path()
	get_parent().get_node("UI/HBoxContainer/Time").value = SIMUL_TIME
	randomize_gene_pool()
	connect("toggle_debug",self,"set_debug")
	connect("begin_simulation",self,"spawn_rocket_generation")
	connect("generation_spawned",get_parent().get_node("UI"),"display_info")
	emit_signal("begin_simulation")


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


func randomize_gene_pool():
	for gene in Genetics.ROCKETS/2:
		add_to_gene_pool(create_child_from_random(Sex.MALE))
	for gene in Genetics.ROCKETS/2:
		add_to_gene_pool(create_child_from_random(Sex.FEMALE))


func add_goal(goal_position):
	goal_positions.append(goal_position)


func add_to_gene_pool(genes:Genes):
	
	var sex_pool = []
	if genes.sex == Sex.MALE:
		sex_pool = gene_pool.fathers
	else:
		sex_pool = gene_pool.mothers
	
	if sex_pool.empty():
		insert_genes(0,genes)
		return
	
	for genes_index in sex_pool.size():
		var other_genes = sex_pool[genes_index]
		if genes.score > other_genes.score:
			insert_genes(genes_index,genes)
			return
	
	insert_genes(sex_pool.size(),genes)

func insert_genes(genes_index,genes):
	if genes.sex == Sex.MALE:
		for copy in Genetics.wives:
			gene_pool.fathers.insert(genes_index,genes)
	else:
		for copy in Genetics.husbands:
			gene_pool.mothers.insert(genes_index,genes)

var draw_positions = []

func get_genetic_score(rocket_position):
	
	var closest_distance = WORLD_BORDERS.length()
	for goal_position in goal_positions:
		var new_distance = (goal_position - rocket_position).length()
		if new_distance < closest_distance:
			closest_distance = new_distance
	
	# closeness_score: 1 ~ on target | 0 ~ too far away
	var closeness_score = get_parent().get_closest_point(rocket_position)
	# timing_score: 1 ~ instant goal | 0 ~ didn't make it
	var timing_score = 1 - simul_time / SIMUL_TIME
	# genetic_score: 1 ~ best | 0 ~ worst
	var genetic_score = (pow(2,closeness_score) - 1 + pow(2,timing_score) - 1) / 2.0
	#print(closeness_score," ",timing_score," ",genetic_score)
	return 3 * closeness_score + timing_score - 1


func spawn_rocket_generation():
	
	print_gene_pool(gene_pool)
	#print("\n")
	var relationships = min(gene_pool.mothers.size(),gene_pool.fathers.size())
	for relation_id in relationships:
		
		var childrens_genes = get_childrens_genes()
		for genes in childrens_genes:
			spawn_rocket(genes)
		
		if get_tree().get_nodes_in_group("rocket").size() >= Genetics.ROCKETS:
			break
	
	var new_rockets_needed = Genetics.ROCKETS - get_tree().get_nodes_in_group("rocket").size()
	for new_rocket_id in max(0,new_rockets_needed):
		spawn_rocket(create_child_from_random())
	
	gene_pool.fathers = []
	gene_pool.mothers = []
	
	emit_signal("generation_spawned")


func spawn_rocket(genes:Genes):
	var rocket = rocket_load.instance()
	rocket.position = $Spawn.position
	connect("end_simulation",rocket,"die")
	connect("toggle_debug",rocket,"set_debug")
	rocket.genes = genes
	rocket.debug = debug
	rocket.update_visuals()
	rocket.thrust_time = SIMUL_TIME / float(Genetics.THRUSTS)
	add_child(rocket)


func get_childrens_genes():
	
	var parents_genes = get_parents_genes()
	var father_genes = parents_genes[0]
	var mother_genes = parents_genes[1]
	if not(mother_genes and father_genes):
		return []
	
	#print(father_genes.first_name," ",father_genes.family_name," + ",
	#mother_genes.first_name," ",mother_genes.family_name," = ")
	
	var has_male_heir = false
	var childrens_genes = []
	var children_to_birth = round(rng.randfn(2.1,0.3))
	for child_index in children_to_birth:
		var child_genes = Genes.new([father_genes,mother_genes])
		#print("   ",child_genes.first_name," ",child_genes.family_name)
		if child_genes.sex == Sex.MALE:
			has_male_heir = true
		childrens_genes.append(child_genes)
	
#	if not has_male_heir:
#		var child_genes = create_child_from_parents(father_genes,mother_genes,Sex.MALE)
#		print("   ",child_genes.first_name," ",child_genes.family_name)
#		childrens_genes.append(child_genes)
	
	return childrens_genes


func get_parents_genes():
	for pot_mother_genes in gene_pool.mothers:
		for pot_father_genes in gene_pool.fathers:
			# incest prevention
			if pot_mother_genes.family_name != pot_father_genes.family_name:
				gene_pool.fathers.erase(pot_father_genes)
				gene_pool.mothers.erase(pot_mother_genes)
				return [pot_father_genes,pot_mother_genes]
	return [null,null]


func create_child_from_random(prefered_sex=-1):
	return Genes.new([],prefered_sex)


func get_random_entry(array:Array,remove:bool = false):
	var index = rng.randi_range(0,array.size()-1)
	var value = array[index]
	if remove:
		array.remove(index)
	return value


func print_gene_pool(gene_pool):
	print("\n\n")
	print("FATHERS")
	for genes in gene_pool.fathers:
		print(genes.first_name + " " + genes.family_name,": ",genes.score)
	print()
	print("MOTHERS")
	for genes in gene_pool.mothers:
		print(genes.first_name + " " + genes.family_name,": ",genes.score)


func _physics_process(delta):
	
	if simul_time >= SIMUL_TIME:
		emit_signal("end_simulation")
		if get_tree().get_nodes_in_group("rocket").empty():
			simul_time -= SIMUL_TIME
			emit_signal("begin_simulation")
	else:
		simul_time += delta
		get_parent().get_node("UI/HBoxContainer/Time/ProgressBar").value = simul_time


func _on_Time_value_changed(value):
	SIMUL_TIME = value



