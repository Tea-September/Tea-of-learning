extends Control

@onready var v: VBoxContainer = $MarginContainer2/HBoxContainer/VBoxContainer
@onready var new_game: Button = $MarginContainer2/HBoxContainer/VBoxContainer/NewGame
@onready var load_game: Button = $MarginContainer2/HBoxContainer/VBoxContainer/LoadGame
@onready var margin_container_3: MarginContainer = $MarginContainer3
@onready var margin_container_2: MarginContainer = $MarginContainer2
@onready var volume_slider: HSlider = $MarginContainer3/VBoxContainer/MarginContainer/HBoxContainer/VolumeSlider

# 控制Master总线的音量
@export var bus: StringName = "Master"
# 返回对应总线的索引号
@onready var bus_index = AudioServer.get_bus_index(bus)


func _ready() -> void:
	# 判断是否拥有存档（即读取存档按钮是否能够按取）
	load_game.disabled = not Game.has_save()
	# 将键盘和鼠标聚焦一致
	new_game.grab_focus()
	for button: Button in v.get_children():
		button.mouse_entered.connect(button.grab_focus)
	SoundManager.setup_ui_sounds(self)
	# 播放标题BGM
	SoundManager.play_bgm(preload("res://Game Assets/Music/title.ogg"))
	# 初始化音量
	volume_slider.value = SoundManager.get_volume(bus_index)
	# 设置音量
	volume_slider.value_changed.connect(func (T: float):
		SoundManager.set_volume(bus_index, T)
		Game.save_config()
	)
	
# 创建新游戏
func _on_new_game_pressed() -> void:
	Game.new_game()

# 读取旧游戏
func _on_load_game_pressed() -> void:
	Game.load_game()

# 退出游戏
func _on_quit_pressed() -> void:
	get_tree().quit()

# 音量设置
func _on_base_set_pressed() -> void:
	margin_container_2.visible = false
	margin_container_3.visible = true

# 返回主菜单
func _on_return_menu_pressed() -> void:
	margin_container_2.visible = true
	margin_container_3.visible = false

# 亮度设置
func _on_light_slider_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
