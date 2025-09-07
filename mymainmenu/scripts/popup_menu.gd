extends MarginContainer

@export var menu_screen : VBoxContainer
@export var open_menu_screen : VBoxContainer
@export var help_margin_container: MarginContainer
@export var set_margin_container: MarginContainer

func menu_visible(object):
	if menu_screen.visible:
		object.visible = false
	else:
		object.visible = true

func _on_togle_menu_button_pressed() -> void:
	menu_visible(menu_screen)
	menu_visible(open_menu_screen)


func _on_help_button_pressed() -> void:
	menu_visible(menu_screen)
	menu_visible(help_margin_container)


func _on_quit_button_pressed() -> void:
	menu_visible(menu_screen)
	menu_visible(set_margin_container)
