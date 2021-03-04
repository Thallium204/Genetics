extends OptionButton

func _ready():
	add_item("FATHER",0)
	add_item("MOTHER",1)
	add_item("SCORE",2)
	selected = Genetics.family_mode


func _on_FamilyModeOptions_item_selected(index):
	Genetics.family_mode = index
