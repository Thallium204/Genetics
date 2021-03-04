extends Node

enum{MALE,FEMALE}
enum{FAMILY_FATHER,FAMILY_MOTHER,FAMILY_SCORE}

const MUTATION_CHANCE = 0.02
const MUTATION_ANGLE = 0.001

const ROCKETS: = 64
const THRUSTS = 50

var family_mode = FAMILY_SCORE
var wives = 1
var husbands = 1

var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


func get_random_sex():
	return rng.randi_range(0,1)
