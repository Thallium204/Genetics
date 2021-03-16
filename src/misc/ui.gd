extends Control

export(NodePath) var family_stats_vbox_path
export(NodePath) var time_slider_path
export(NodePath) var wives_spin_box_path
export(NodePath) var husbands_spin_box_path

var last_family_names = []
var family_populations = {}

var family_to_labels = {} # "HENDRICK" : {"name":Label, "pop":Label, ...}

onready var family_stats_vbox = get_node(family_stats_vbox_path)
onready var time_slider = get_node(time_slider_path)
onready var wives_spin_box = get_node(wives_spin_box_path)
onready var husbands_spin_box = get_node(husbands_spin_box_path)


func _ready():
	time_slider.value = Genetics.SIMUL_TIME
	wives_spin_box.value = Genetics.wives
	husbands_spin_box.value = Genetics.husbands

func display_info():
	
	for label in family_stats_vbox.get_children():
		label.free()
	
	var rocket_array = get_tree().get_nodes_in_group("rocket")
	family_populations = {}
	
	var largest_pop = 0
	for rocket in rocket_array:
		var family_name = rocket.genes.family_name
		if family_populations.has(family_name):
			family_populations[family_name].pop += 1
		else:
			family_populations[family_name] = {"pop":1,"reported":0,"max_score":rocket.genes.score}
		if family_populations[family_name].pop > largest_pop:
			largest_pop = family_populations[family_name].pop
	
	for pop in range(largest_pop,0,-1):
		for family_name in family_populations:
			var pop_info = family_populations[family_name]
			if pop_info.pop == pop:
				var name_label = Label.new()
				if family_name in last_family_names:
					name_label.modulate = Lineage.get_family_colors(family_name)
				name_label.text = family_name
				family_stats_vbox.add_child(name_label)
				var pop_label = Label.new()
				pop_label.text = str(pop_info.pop)
				family_stats_vbox.add_child(pop_label)
				var score_label = Label.new()
				score_label.text = str(pop_info.max_score)
				family_stats_vbox.add_child(score_label)
				family_to_labels[family_name] = {
					"family_name":name_label,
					"pop":pop_label,
					"max_score":score_label,
					}
	
	last_family_names = []
	for family_name in family_populations:
		last_family_names.append(family_name)


func update_labels(genes:Genes):
	var family_data = family_populations[genes.family_name]
	if genes.score > family_data.max_score:
		family_data.max_score = genes.score
		var label_node = family_to_labels[genes.family_name].max_score
		label_node.text = str(stepify(family_data.max_score,0.01))


func _on_Wives_value_changed(value):
	Genetics.wives = value


func _on_Husbands_value_changed(value):
	Genetics.husbands = value


func _on_Button_toggled(button_pressed):
	var to_margin = -$BottomBar/Options.rect_size.y
	to_margin *= int(button_pressed)
	$Tween.interpolate_property($BottomBar,"margin_top",
	null,to_margin,0.1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
