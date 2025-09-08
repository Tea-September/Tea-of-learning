extends CanvasLayer

@export var panel: Panel
var nowTime: float


func _process(delta: float) -> void:
	var purposeMusic = 0.0 if get_tree().paused else 1.0
	BackgroundMusic.volume_linear = lerp(BackgroundMusic.volume_linear, purposeMusic, delta * 10.0)
	
	BackgroundMusic.stream_paused = get_tree().paused and Time.get_ticks_msec() > nowTime + 300 
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if get_tree().paused:
				startGame()
			else:
				stopGame()

func stopGame():
	nowTime = Time.get_ticks_msec()
	get_tree().paused = true
	panel.visible = true
	
func startGame():
	get_tree().paused = false
	panel.visible = false
	
func quitGame():
	get_tree().quit()
