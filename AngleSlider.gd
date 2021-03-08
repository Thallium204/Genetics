extends HSlider


func _ready():
	value = Genetics.MUTATION_ANGLE
	update_ui()


func _on_Chance_value_changed(value):
	Genetics.MUTATION_ANGLE = value
	update_ui()


func update_ui():
	$Back.value = value
	get_node("../Label").text = str(value)
