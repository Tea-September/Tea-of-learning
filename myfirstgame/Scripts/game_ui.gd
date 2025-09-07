extends CanvasLayer

@export var gameUI: Control
var newTime: float


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if get_tree( ).paused:
				replayGame()
			else:
				stopGame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var purposeBgm = 0.0 if get_tree( ).paused else 1.0
	Bgm.volume_linear = lerp(Bgm.volume_linear, purposeBgm, delta * 10.0)
	Bgm.stream_paused = get_tree( ).paused and Time.get_ticks_msec() > newTime + 500

func stopGame():
	get_tree( ).paused = true
	gameUI.visible = true
	newTime = Time.get_ticks_msec()

func replayGame():
	get_tree( ).paused = false
	gameUI.visible = false
	
func quitGame():
	get_tree( ).quit()
