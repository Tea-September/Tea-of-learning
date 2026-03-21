class_name PlotPeopleInteractable
extends Interactable

@onready var plot_people: PlotPeople = $"../../../PlotPeople"

# 人物对话
func interact() -> void:
	# 由于父类内容被覆盖，重新调用父类的方法
	super()
	plot_people.visible = true
	get_tree( ).paused = true
