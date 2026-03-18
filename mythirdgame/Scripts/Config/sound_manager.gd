extends Node

@onready var sfx: Node = $SFX
@onready var world_bgm: AudioStreamPlayer = $WorldBgm
@onready var run: AudioStreamPlayer = $SFX/Run
@onready var if_run: bool = true

# 音效播放
func play_sfx(name: String) -> void:
	var player = sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()

# 场景BGM播放
func play_bgm(stream: AudioStream) -> void:
	if world_bgm.stream == stream and world_bgm.playing:
		return
	world_bgm.stream = stream
	world_bgm.play()

func setup_ui_sounds(node: Node) -> void:
	var button = node as Button
	if button:
		button.pressed.connect(play_sfx.bind("UIPress"))
		button.focus_entered.connect(play_sfx.bind("UIFocus"))
		
	for child in node.get_children():
		setup_ui_sounds(child)
