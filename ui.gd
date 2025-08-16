extends CanvasLayer

var time: Label
var bladder_slider: Control
var hunger_slider: Control
var energy_slider: Control
var fun_slider: Control

var action_queue: Control
var action_item_scene: PackedScene

var game_over_screen: Control

func _ready():
	time = get_node("Time")
	energy_slider = get_node("Sliders/EnergySlider")
	hunger_slider = get_node("Sliders/HungerSlider")
	bladder_slider = get_node("Sliders/BladderSlider")
	fun_slider = get_node("Sliders/FunSlider")
	action_queue = get_node("ActionQueue")
	Global.player.action_queue_updated.connect(_on_player_action_queue_updated)
	action_item_scene = load("res://action_item.tscn")
	game_over_screen = get_node("GameOverScreen")


func _process(_delta: float) -> void:
	set_time_label()
	#set_current_action_label()
	set_needs_sliders()
	if Global.game_over:
		game_over_screen.visible = true
		game_over_screen.get_node("Reason").text = "Bowling Bob died of "
		game_over_screen.get_node("Reason").text += Global.game_over_reason
	

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			GameTime.set_current_time_scale(GameTime.TIME_SCALE_PRESET_1)
		elif event.keycode == KEY_2:
			GameTime.set_current_time_scale(GameTime.TIME_SCALE_PRESET_2)
		elif event.keycode == KEY_3:
			GameTime.set_current_time_scale(GameTime.TIME_SCALE_PRESET_3)
		elif event.keycode == KEY_4:
			GameTime.set_current_time_scale(GameTime.TIME_SCALE_PRESET_4)
		elif event.keycode == KEY_5:
			GameTime.set_current_time_scale(GameTime.TIME_SCALE_PRESET_5)


func _on_player_action_queue_updated() -> void:
	var action_queue_container = action_queue.get_node("Container")
	for child in action_queue_container.get_children():
		child.queue_free()
	
	for action in Global.player.action_queue:
		var action_item = action_item_scene.instantiate()
		action_item.init(action)
		action_item.action_canceled.connect(_on_action_queue_item_canceled)
		action_queue_container.add_child(action_item)


func _on_action_queue_item_canceled(action: Player.Action):
	Global.player.remove_action(action)
	print("Action queue item canceled " + action.get_string())

func set_time_label() -> void:
	var day = GameTime.get_current_day()
	var hour = GameTime.get_current_hour()
	var minute = GameTime.get_current_minute()
	var s = GameTime.get_current_time_scale()
	time.text = "Day %d: %02d:%02d (Time Scale: %.0fx)" % [day, hour, minute, s]
	

func set_needs_sliders() -> void:
	energy_slider.set_percent(Global.player.energy)
	hunger_slider.set_percent(Global.player.hunger)
	bladder_slider.set_percent(Global.player.bladder)
	fun_slider.set_percent(Global.player.fun)
