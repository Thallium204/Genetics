extends TileMap

signal begin_simulation
signal end_simulation

var rng = RandomNumberGenerator.new()
var rocket_load = preload("res://Rocket.tscn")

enum Sex{MALE,FEMALE}

const ROCKETS: = 32

const POOL_MAX: = 25 # Maximum number of gene copies added
const POOL_MIN: = 1 # Minimum number of gene copies added
const MUTATION_CHANCE = 0.05
const MUTATION_ANGLE = 0.01

const thrust_length:int = 50
const SIMUL_TIME:float = 16.0
var simul_time:float = 0.0 # seconds

onready var WORLD_BORDERS = get_tree().get_root().size

var family_names = []
var male_names = []
var female_names = []

var goal_positions:PoolVector2Array
var gene_pool = {"fathers":[],"mothers":[]}
var family_colors = {}

func _ready():
	rng.randomize()
	import_names()
	fill_floor()
	get_parent().update_path()
	randomize_gene_pool()
	connect("begin_simulation",self,"spawn_rockets")
	emit_signal("begin_simulation")


func import_names():
	
	var file = File.new()
	file.open("last-names.json", File.READ)
	family_names = parse_json(file.get_line())
	file.close()
	file.open("male-names.json", File.READ)
	male_names = parse_json(file.get_line())
	file.close()
	file.open("female-names.json", File.READ)
	female_names = parse_json(file.get_line())
	file.close()


func convert_txt_to_json(file_name=""):
	var file = File.new()
	file.open(file_name+".txt", File.READ)
	var content = file.get_as_text().split("\n")
	file.close()
	
	file.open(file_name+".json", File.WRITE)
	file.store_line(to_json(content))
	file.close()


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
	for gene in ROCKETS/2:
		add_to_gene_pool(generate_random_gene(Sex.MALE))
	for gene in ROCKETS/2:
		add_to_gene_pool(generate_random_gene(Sex.FEMALE))


func add_goal(goal_position):
	goal_positions.append(goal_position)


func add_genes(genes,rocket_position):
	
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
	
	genes.genetic_score = genetic_score
	
	add_to_gene_pool(genes)


func add_to_gene_pool(genes):
	
	var sex_pool = []
	if genes.sex == Sex.MALE:
		sex_pool = gene_pool.fathers
	else:
		sex_pool = gene_pool.mothers
	
	if sex_pool.empty():
		sex_pool.append(genes)
		return
	
	for genes_index in sex_pool.size():
		var other_genes = sex_pool[genes_index]
		if genes.genetic_score > other_genes.genetic_score:
			sex_pool.insert(genes_index,genes)
			return
	
	sex_pool.append(genes)


func spawn_rockets():
	
	#print_gene_pool(gene_pool)
	print("\n")
	var relationships = min(gene_pool.mothers.size(),gene_pool.fathers.size())
	for relation_id in min(gene_pool.mothers.size(),gene_pool.fathers.size()):
		
		var childrens_genes = get_childrens_genes()
		for genes in childrens_genes:
		
			var rocket = rocket_load.instance()
			rocket.position = $Spawn.position
			connect("end_simulation",rocket,"die")
			rocket.genes = genes
			rocket.update_visuals(family_colors[genes.family_name])
			rocket.thrust_time = SIMUL_TIME / float(thrust_length)
			add_child(rocket)
	
	gene_pool.fathers = []
	gene_pool.mothers = []


func get_childrens_genes():
	
	var father_genes = {}
	var mother_genes = {}
	for pot_mother_genes in gene_pool.mothers:
		for pot_father_genes in gene_pool.fathers:
			# incest prevention
			if pot_mother_genes.family_name != pot_father_genes.family_name:
				father_genes = pot_father_genes
				gene_pool.fathers.erase(pot_father_genes)
				mother_genes = pot_mother_genes
				gene_pool.mothers.erase(pot_mother_genes)
				break
	if mother_genes.empty() or father_genes.empty():
		return []
	
	print(father_genes.first_name," ",father_genes.family_name," + ",
	mother_genes.first_name," ",mother_genes.family_name," = ")
	
	var has_male_heir = false
	var childrens_genes = []
	var children_to_birth = round(rng.randf_range(1.0,3.2))
	for child_index in 3:
		var child_genes = create_child_from_parents(father_genes,mother_genes)
		print("   ",child_genes.first_name," ",child_genes.family_name)
		if child_genes.sex == Sex.MALE:
			has_male_heir = true
		childrens_genes.append(child_genes)
	
	if not has_male_heir:
		var child_genes = create_child_from_parents(father_genes,mother_genes)
		print("   ",child_genes.first_name," ",child_genes.family_name)
		childrens_genes.append(child_genes)
	
	return childrens_genes


func create_child_from_parents(father_genes,mother_genes,prefered_sex=-1):
	var sex = rng.randi_range(0,1) if prefered_sex < 0 else prefered_sex
	var first_name = get_random_first_name(sex)
	var family_name = father_genes.family_name
	
	var thrust_sequence = PoolVector2Array()
	for index in thrust_length:
		thrust_sequence.append(father_genes.thrust_sequence[index] if index % 2 == 0 else mother_genes.thrust_sequence[index])
	thrust_sequence = mutate(thrust_sequence)
	
	return { 
			"genetic_score":0.0,
			"sex":sex,
			"first_name": first_name,
			"family_name": family_name,
			"thrust_sequence":thrust_sequence,
	}


func generate_random_gene(prefered_sex=-1):
	
	var family_name = get_random_entry(family_names,true)
	family_colors[family_name] = Color(rng.randf_range(0,1),rng.randf_range(0,1),rng.randf_range(0,1))
	
	var sex:int
	if prefered_sex >= 0:
		sex = prefered_sex
	else:
		sex = rng.randi_range(0,1)
	
	var first_name = get_random_first_name(sex)
	
	var thrust_sequence = PoolVector2Array()
	for thrust in thrust_length:
		thrust_sequence.append(get_random_vector())
	
	return { 
			"genetic_score":0.0,
			"sex":sex,
			"first_name": first_name,
			"family_name": family_name,
			"thrust_sequence":thrust_sequence,
	}


func mutate(thrust_sequence):
	for index in thrust_sequence.size(): # mutate genes
		if rng.randf_range(0,1) <= MUTATION_CHANCE:
			thrust_sequence[index] = get_random_vector()
		else:
			thrust_sequence[index] = thrust_sequence[index].rotated(2*PI * MUTATION_ANGLE * rng.randf_range(-1,1))
	return thrust_sequence


func get_random_first_name(sex):
	if sex == Sex.MALE:
		return get_random_entry(male_names)
	else:
		return get_random_entry(female_names)


func get_random_vector():
	var angle = rng.randf_range(0,360)
	return Vector2(sin(angle),cos(angle))


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
		print("  name = ",genes.first_name + " " + genes.family_name)
		print("  score = ",genes.genetic_score)
	print()
	print("MOTHERS")
	for genes in gene_pool.mothers:
		print("  name = ",genes.first_name + " " + genes.family_name)
		print("  score = ",genes.genetic_score)
	


func _physics_process(delta):
	
	simul_time += delta
	if simul_time >= SIMUL_TIME:
		emit_signal("end_simulation")
		emit_signal("begin_simulation")
		simul_time -= SIMUL_TIME


