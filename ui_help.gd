extends Control

var help_text: Label
var shown_button: Button
var bg: ColorRect

func _ready():
	help_text = get_node("HelpText")
	shown_button = get_node("Shown")
	bg = get_node("Bg")

func _on_shown_toggled(toggled_on: bool) -> void:
	help_text.visible = toggled_on
	bg.visible = toggled_on
	if toggled_on:
		shown_button.text = "Hide help"
	else:
		shown_button.text = "Show help"
		
