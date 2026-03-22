class_name Plot
extends Interactable

@onready var plot_text = {
	"森林里的生物怎么变得这么狂暴，森林深处一定发生了大事情！" : 1,
	"这些卢恩文字，到底具有什么含义？" : 2,
	"居然是史莱姆，不好对付呀！" : 3,
	"这里的地形真是险峻！" : 4,
	"终于出来了，马上就要进入丛林深处了，做好准备！" : 5
}

@export var plot_point: int
@onready var label: Label = $"../../../Plot/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer/NinePatchRect/MarginContainer/Label"
@onready var plot: CanvasLayer = $"../../../Plot"
@onready var quit_menu: Button = $"../../../Plot/MarginContainer/NinePatchRect/VBoxContainer/MarginContainer2/QuitMenu"

# 显示剧情文本
func interact() -> void:
	# 由于父类内容被覆盖，重新调用父类的方法
	super()
	# 遍历所有键（文本）
	for T in plot_text:
		if plot_point == plot_text[T]:
			label.text = T
			break
	plot.visible = true
	get_tree( ).paused = true
	# 将键盘和鼠标聚焦一致
	quit_menu.grab_focus()
