extends Navigation2D

var curve:Curve2D = Curve2D.new()
var best_path:PoolVector2Array

func update_path():
	best_path = get_simple_path($Map/Spawn.position,$Map/Goal.position)
	$BestPath.points = best_path
	for point in best_path:
		curve.add_point(point)
	#print(curve.get_baked_length())


func get_closest_point(rocket_position):
	return curve.get_closest_offset(rocket_position)/curve.get_baked_length()


func _on_Debug_toggled(button_pressed):
	$BestPath.visible = button_pressed
	$Map.emit_signal("toggle_debug",button_pressed)
