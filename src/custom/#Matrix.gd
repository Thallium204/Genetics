class_name Matrix
extends Resource

var rows:int
var cols:int

var array_2D = []

func _init(variant, cols_value = 1, random = false):
	
	if variant is int:
	
		rows = variant
		cols = cols_value
		
		for r_index in rows:
			array_2D.append([])
			for c_index in cols:
				if random:
					array_2D[-1].append(rand_range(0,1))
				else:
					array_2D[-1].append(0)
	
	elif variant is Array:
		
		array_2D = variant
		rows = array_2D.size()
		cols = array_2D[0].size()


func set_index(value, row, col = 1):
	array_2D[row][col] = value


func adj_index(adjust, row, col = 1):
	array_2D[row][col] += adjust


func mult(matrix:Matrix):
	
	if rows != matrix.cols or cols != matrix.rows:
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


func p():
	var print_string = ""
	for row in array_2D:
		print_string = "["
		for value in row:
			print_string += "%5d," % value
		print(print_string.left(print_string.length()-1) + "]")


var format_string = "%s was reluctant to learn %s, but now he enjoys it."
var actual_string = format_string % ["Estragon", "GDScript"]

