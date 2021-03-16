class_name Network
extends Resource

var input_size = 1 setget set_input_size
var hidden_size = 1 setget set_hidden_size
var output_size = 1 setget set_output_size

var input_layer = []

var hidden_matrix = []
var hidden_layer = []
var hidden_recurse = []

var output_matrix = []
var output_layer = []


func set_input_size(value):
	input_size = value
	configure_layer(input_layer,input_size)

func set_hidden_size(value):
	hidden_size = value
	configure_layer(hidden_layer,hidden_size)

func set_output_size(value):
	output_size = value
	configure_layer(output_layer,output_size)

func configure_layer(layer,size):
	for node in size:
		input_layer.append(NetNode.new())
