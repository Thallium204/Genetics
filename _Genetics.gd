extends Node

enum{MALE,FEMALE}

const MUTATION_CHANCE = 0.05
const MUTATION_ANGLE = 0.01

const ROCKETS: = 64
const THRUSTS = 50

var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


func get_random_sex():
	return rng.randi_range(0,1)
