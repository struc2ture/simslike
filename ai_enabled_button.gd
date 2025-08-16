extends Button


func _on_toggled(toggled_on: bool) -> void:
	text = "AI "
	if toggled_on:
		text += "Enabled"
	else:
		text += "Disabled"
	Global.ai_enabled = toggled_on
