class_name Matrix
extends Resource

var rows:int
var cols:int

var array_2D = []

func _init(variant, cols_value = 1, random = false, random_size = 1.0):
	randomize()
	
	if variant is int:
	
		rows = variant
		cols = cols_value
		
		for r_index in rows:
			array_2D.append([])
			for c_index in cols:
				if random:
					array_2D[-1].append(random_size * rand_range(-1,1))
				else:
					array_2D[-1].append(0)
	
	elif variant is Array:
		
		array_2D = variant
		rows = array_2D.size()
		cols = array_2D[0].size()


func set_index(value, row, col = 0):
	array_2D[row][col] = value


func adj_index(adjust, row, col = 0):
	array_2D[row][col] += adjust


func add(matrix:Matrix):
	
	if rows != matrix.rows or cols != matrix.cols:
		push_error("MATRIX LINEAR MULT ERROR: ("+str(rows)+","+str(cols)+") x ("+str(matrix.rows)+","+str(matrix.cols)+")")
	
	var outcome_array_2D = []
	
	for row in rows:
		outcome_array_2D.append([])
		for col in cols:
			outcome_array_2D[-1].append(array_2D[row][col] + matrix.array_2D[row][col])
	
	return outcome_array_2D


func mult(matrix:Matrix):
	
	if cols != matrix.rows:
		push_error("MATRIX MULT ERROR: ("+str(rows)+","+str(cols)+") x ("+str(matrix.rows)+","+str(matrix.cols)+")")
	
	var outcome_array_2D = []
	
	for row in rows:
		outcome_array_2D.append([])
		for col in matrix.cols:
			outcome_array_2D[-1].append(0)
			for iter in cols:
				var value = array_2D[row][iter] * matrix.array_2D[iter][col]
				outcome_array_2D[row][col] += value
	
	return outcome_array_2D


func linear_mult(matrix:Matrix):
	
	if rows != matrix.rows or cols != matrix.cols:
		push_error("MATRIX LINEAR MULT ERROR: ("+str(rows)+","+str(cols)+") x ("+str(matrix.rows)+","+str(matrix.cols)+")")
	
	var outcome_array_2D = []
	
	for row in rows:
		outcome_array_2D.append([])
		for col in cols:
			outcome_array_2D[-1].append(array_2D[row][col] * matrix.array_2D[row][col])
	
	return outcome_array_2D


func apply_sigmoid():
	
	for row in rows:
		for col in cols:
			array_2D[row][col] = 1.0 / ( 1 + exp(-array_2D[row][col]) )


func to_array() -> Array:
	
	var array = []
	for row in array_2D:
		array.append(row[0])
	
	return array


func p(print_name = ""):
	print(print_name)
	var print_string = ""
	for row in array_2D:
		print_string = " | "
		for value in row:
			print_string += "%-6.2f" % float(value)
		print(print_string.left(print_string.length()-2) + " |")




