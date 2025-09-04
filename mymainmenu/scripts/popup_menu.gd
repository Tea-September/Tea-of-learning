extends MarginContainer

@export var menu_screen : VBoxContainer
@export var open_menu_screen : VBoxContainer

func menu_visible(object):
	if menu_screen.visible:
		object.visible = false
	else:
		object.visible = true

func _on_togle_menu_button_pressed() -> void:
	menu_visible(menu_screen)
	menu_visible(open_menu_screen)
