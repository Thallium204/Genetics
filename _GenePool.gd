extends Node

var gene_pool = {"fathers":[],"mothers":[]}

var rng = RandomNumberGenerator.new()

func _init():
	rng.randomize()

func randomize_gene_pool():
	for gene in int(Genetics.ROCKETS/2.0):
		add_to_gene_pool(create_child_from_random(Genetics.MALE))
	for gene in int(Genetics.ROCKETS/2.0):
		add_to_gene_pool(create_child_from_random(Genetics.FEMALE))


func add_to_gene_pool(genes:Genes):
	
	var sex_pool = []
	if genes.sex == Genetics.MALE:
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
	if genes.sex == Genetics.MALE:
		for copy in Genetics.wives:
			gene_pool.fathers.insert(genes_index,genes)
	else:
		for copy in Genetics.husbands:
			gene_pool.mothers.insert(genes_index,genes)


func get_parents_genes():
	for pot_mother_genes in gene_pool.mothers:
		for pot_father_genes in gene_pool.fathers:
			# incest prevention
			if pot_mother_genes.family_name != pot_father_genes.family_name:
				gene_pool.fathers.erase(pot_father_genes)
				gene_pool.mothers.erase(pot_mother_genes)
				return [pot_father_genes,pot_mother_genes]
	return [null,null]


func create_childrens_genes():
	
	var parents_genes = GenePool.get_parents_genes()
	var father_genes = parents_genes[0]
	var mother_genes = parents_genes[1]
	if not(mother_genes and father_genes):
		return []
	
	#print(father_genes.first_name," ",father_genes.family_name," + ",
	#mother_genes.first_name," ",mother_genes.family_name," = ")
	
	var _has_male_heir = false
	var childrens_genes = []
	var children_to_birth = round(rng.randfn(2.1,0.3))
	for child_index in children_to_birth:
		var child_genes = Genes.new([father_genes,mother_genes])
		#print("   ",child_genes.first_name," ",child_genes.family_name)
		if child_genes.sex == Genetics.MALE:
			_has_male_heir = true
		childrens_genes.append(child_genes)
	
#	if not has_male_heir:
#		var child_genes = create_child_from_parents(father_genes,mother_genes,Sex.MALE)
#		print("   ",child_genes.first_name," ",child_genes.family_name)
#		childrens_genes.append(child_genes)
	
	return childrens_genes


func create_child_from_random(prefered_sex=-1):
	return Genes.new([],prefered_sex)


func empty_pool():
	gene_pool.fathers = []
	gene_pool.mothers = []


func get_relationships():
	return min(gene_pool.mothers.size(),gene_pool.fathers.size())


func print_gene_pool():
	print("\n\n")
	print("FATHERS")
	for genes in gene_pool.fathers:
		print(genes.first_name + " " + genes.family_name,": ",genes.score)
	print()
	print("MOTHERS")
	for genes in gene_pool.mothers:
		print(genes.first_name + " " + genes.family_name,": ",genes.score)

