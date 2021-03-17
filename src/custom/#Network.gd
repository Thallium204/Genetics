class_name Network
extends Resource

var input_size = 1
var hidden_size = 1
var output_size = 1

var input_vector = []

var hidden_matrix = []
var hidden_vector = []
var hidden_r_vector = []

var output_matrix = []
var output_vector = []


func _init(input:int, hidden:int, output:int):
	
	input_size = input
	hidden_size = hidden
	output_size = output
	
	input_vector = Matrix.new(input)
	hidden_matrix = Matrix.new(hidden_size,input_size,true)
	hidden_vector = Matrix.new(input)
	hidden_r_vector = Matrix.new(hidden)
	output_matrix = Matrix.new(output_size,hidden_size,true)
	output_vector = Matrix.new(output)

	print_internals()

func print_internals():
	
	input_vector.p()
	hidden_matrix.p()
	hidden_vector.p()
	hidden_r_vector.p()
	output_matrix.p()
	output_vector.p()
