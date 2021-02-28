extends Control

var last_family_names = []
var family_populations = {}

var family_to_labels = {} # "HENDRICK" : {"name":Label, "pop":Label, ...}

func display_info():
	
	for label in $VBox/GridContainer.get_children():
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
				$VBox/GridContainer.add_child(name_label)
				var pop_label = Label.new()
				pop_label.text = str(pop_info.pop)
				$VBox/GridContainer.add_child(pop_label)
				var score_label = Label.new()
				score_label.text = str(pop_info.max_score)
				$VBox/GridContainer.add_child(score_label)
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
