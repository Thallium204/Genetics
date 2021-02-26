class_name Genes, "res://icons/Genes.svg"
extends Resource

var first_name:String
var family_name:String
var sex:int = 0
var thrust_sequence:PoolVector2Array
var score:float = 0.0

func _init(parents_genes = [], prefered_sex = -1):
	
	sex = Genetics.get_random_sex() if prefered_sex < 0 else prefered_sex
	first_name = Lineage.get_random_first_name(sex)
	
	if parents_genes.empty():
		
		family_name = Lineage.create_new_family_lineage()
		for index in Genetics.THRUSTS:
			thrust_sequence.append(get_random_vector())
		
	else:
		
		var father_genes = parents_genes[0]
		var mother_genes = parents_genes[1]
		family_name = father_genes.family_name
		
		for index in Genetics.THRUSTS:
			var new_thrust = (father_genes.thrust_sequence[index] + mother_genes.thrust_sequence[index]).normalized()
			thrust_sequence.append(new_thrust)


func mutate():
	for index in thrust_sequence.size(): # mutate genes
		if rand_range(0,1) <= Genetics.MUTATION_CHANCE:
			thrust_sequence[index] = get_random_vector()
		else:
			thrust_sequence[index] = thrust_sequence[index].rotated(2*PI * Genetics.MUTATION_ANGLE * rand_range(-1,1))
	return thrust_sequence


func get_random_vector():
	var angle = rand_range(0.0,360.0)
	return Vector2(sin(angle),cos(angle))
