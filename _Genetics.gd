extends Node

enum{MALE,FEMALE}
enum{FAMILY_FATHER,FAMILY_MOTHER,FAMILY_SCORE}

var MUTATION_CHANCE = 0.05
var MUTATION_ANGLE = 0.01

const ROCKETS: = 64
const THRUSTS = 50

var SIMUL_TIME:float = 10.0

var family_mode = FAMILY_FATHER
var wives = 1
var husbands = 1

var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


func get_random_sex():
	return rng.randi_range(0,1)
