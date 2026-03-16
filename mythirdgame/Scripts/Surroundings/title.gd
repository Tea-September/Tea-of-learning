extends Control

@onready var new_game: Button = $MarginContainer2/HBoxContainer/VBoxContainer/NewGame
@onready var v: VBoxContainer = $MarginContainer2/HBoxContainer/VBoxContainer
@onready var load_game: Button = $MarginContainer2/HBoxContainer/VBoxContainer/LoadGame

func _ready() -> void:
	# 判断是否拥有存档（即读取存档按钮是否能够按取）
	load_game.disabled = not Game.has_save()
	# 将键盘和鼠标聚焦一致
	new_game.grab_focus()
	for button: Button in v.get_children():
		button.mouse_entered.connect(button.grab_focus)
	
# 创建新游戏
func _on_new_game_pressed() -> void:
	Game.new_game()

# 读取旧游戏
func _on_load_game_pressed() -> void:
	Game.load_game()

# 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()
