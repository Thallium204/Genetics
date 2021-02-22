extends TileMap

const POOL_MAX = 5 # Maximum number of gene copies added
const POOL_MIN = 1 # Minimum number of gene copies added
onready var DISTANCE_MAX = get_tree().get_root().size.length()

var goal_positions:PoolVector2Array
var gene_pool:Array

func _ready():
	print(DISTANCE_MAX)


func add_goal(goal_position):
	goal_positions.append(goal_position)


func add_genes(thrust_sequence,rocket_position):
	
	var genetic_score = 0.0
	var closest_distance = 0.0
	for goal_position in goal_positions:
		pass
