class_name Network
extends Resource

var input_size = 1
var hidden_size = 1
var output_size = 1

var input_vector:Matrix

var hidden_matrix :Matrix
var hidden_vector:Matrix
var hidden_r_vector:Matrix
var hidden_bias:Matrix

var output_matrix:Matrix
var output_vector:Matrix
var output_bias:Matrix


func _init(input:int, hidden:int, output:int):
	
	input_size = input
	hidden_size = hidden
	output_size = output
	
	input_vector = Matrix.new(input)
	
	hidden_matrix = Matrix.new(hidden_size,input_size,true)
	hidden_vector = Matrix.new(hidden)
	hidden_bias = Matrix.new(hidden,1,true,2)
	
	hidden_r_vector = Matrix.new(hidden,1,true)
	
	output_matrix = Matrix.new(output_size,hidden_size,true)
	output_vector = Matrix.new(output)
	output_bias = Matrix.new(output,1,true,2)

	print_matrices()


func set_input(array):
	
	for index in array.size():
		var variant = array[index]
		var post_value:float
		if variant is Color:
			post_value = variant.r + variant.g + variant.b
		input_vector.set_index(post_value,index)


func feed_forward():
	
	var input_recurse = Matrix.new(hidden_vector.linear_mult(hidden_r_vector))
	var input_matrix = Matrix.new(hidden_matrix.mult(input_vector))
	hidden_vector = Matrix.new(input_matrix.add(input_recurse))
	hidden_vector = Matrix.new(hidden_vector.add(hidden_bias))
	hidden_vector.apply_sigmoid()
	
	output_vector = Matrix.new(output_matrix.mult(hidden_vector))
	output_vector = Matrix.new(output_vector.add(output_bias))
	output_vector.apply_sigmoid()
	
	return output_vector.to_array()


func print_internals():
	print()
	input_vector.p("input_vector")
	hidden_matrix.p("hidden_matrix")
	hidden_vector.p("hidden_vector")
	hidden_r_vector.p("hidden_r_vector")
	output_matrix.p("output_matrix")
	output_vector.p("output_vector")


func print_vectors():
	print()
	input_vector.p("input_vector")
	hidden_vector.p("hidden_vector")
	output_vector.p("output_vector")


func print_matrices():
	print()
	hidden_matrix.p("hidden_matrix")
	output_matrix.p("output_matrix")




