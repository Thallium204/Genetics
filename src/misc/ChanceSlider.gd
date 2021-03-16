extends HSlider


func _ready():
	value = Genetics.MUTATION_CHANCE
	update_ui()


func _on_Chance_value_changed(value):
	Genetics.MUTATION_CHANCE = value
	update_ui()


func update_ui():
	$Back.value = 100 * Genetics.MUTATION_CHANCE
	$Perc.value = 100 * Genetics.MUTATION_CHANCE
