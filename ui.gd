extends Control

var last_family_names = []

func display_info():
	
	for label in $VBox/GridContainer.get_children():
		label.free()
	
	var rocket_array = get_tree().get_nodes_in_group("rocket")
	var family_populations = {}
	
	var largest_pop = 0
	for rocket in rocket_array:
		var family_name = rocket.genes.family_name
		if family_populations.has(family_name):
			family_populations[family_name] += 1
		else:
			family_populations[family_name] = 1
		if family_populations[family_name] > largest_pop:
			largest_pop = family_populations[family_name]
	
	for pop in range(largest_pop,0,-1):
		for family_name in family_populations:
			if family_populations[family_name] == pop:
				var label = Label.new()
				if family_name in last_family_names:
					label.modulate = Color.red
				label.text = family_name + ": " + str(pop)
				$VBox/GridContainer.add_child(label)
	
	last_family_names = []
	for family_name in family_populations:
		last_family_names.append(family_name)
