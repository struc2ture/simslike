extends HBoxContainer

var action_name: Label
var cancel_button: Button

var action: Player.Action

signal action_canceled(action: Player.Action)


func init(action: Player.Action):
	self.action = action


func _ready():
	action_name = get_node("ActionName")
	action_name.text = action.get_string()
	cancel_button = get_node("CancelButton")
	cancel_button.pressed.connect(_on_cancel)


func _on_cancel():
	action_canceled.emit(action)
