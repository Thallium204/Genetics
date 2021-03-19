extends Node

var rng = RandomNumberGenerator.new()

var lineage = {}

var family_names = []
var family_index = 0

var male_names = []
var male_index = 0
var female_names = []
var female_index = 0


func _init():
	rng.randomize()
	import_names()
	randomize_name_orders()


func import_names():
	
	var file = File.new()
	file.open("assets/data/last-names.json", File.READ)
	family_names = parse_json(file.get_line())
	file.close()
	file.open("assets/data/male-names.json", File.READ)
	male_names = parse_json(file.get_line())
	file.close()
	file.open("assets/data/female-names.json", File.READ)
	female_names = parse_json(file.get_line())
	file.close()


func randomize_name_orders():
	family_names.shuffle()
	male_names.shuffle()
	female_names.shuffle()


func get_random_first_name(sex):
	if sex == Genetics.MALE:
		male_index = (male_index + 1) % male_names.size()
		return male_names[male_index]
	else:
		female_index = (female_index + 1) % female_names.size()
		return female_names[female_index]


func create_new_family_lineage():
	family_index += 1
	var family_name = family_names[family_index]
	lineage[family_name] = {"color":get_random_color()}
	return family_name


func get_family_colors(family_name):
	return lineage[family_name].color


func get_random_color():
	return Color(rng.randf_range(0,1),rng.randf_range(0,1),rng.randf_range(0,1))


func convert_txt_to_json(file_name=""):
	var file = File.new()
	file.open(file_name+".txt", File.READ)
	var content = file.get_as_text().split("\n")
	file.close()
	
	file.open(file_name+".json", File.WRITE)
	file.store_line(to_json(content))
	file.close()

