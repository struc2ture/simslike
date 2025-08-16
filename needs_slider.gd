extends Control

@export var need_name: String

var fg_rect: ColorRect
var label: Label

func _ready():
	fg_rect = get_node("FgRect")
	label = get_node("Label")
	if need_name:
		label.text = need_name

func set_percent(percent: float) -> void:
	if percent > 1.0:
		percent = 1.0
	elif percent < 0.0:
		percent = 0.0
	fg_rect.scale.x = percent
	
