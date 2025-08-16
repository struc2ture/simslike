class_name Player extends Node3D

@export var speed: float = 3.0

var action_queue: Array[Action]
signal action_queue_updated
signal died(reason: String)

var energy: float = 1.0
var hunger: float = 0.2
var bladder: float = 0.2
var fun: float = 0.5

var ENERGY_DRAIN = -GameTime.time_to_zero(GameTime.hours(18))
var HUNGER_DRAIN = -GameTime.time_to_zero(GameTime.hours(10))
var BLADDER_DRAIN = -GameTime.time_to_zero(GameTime.hours(3))
var FUN_DRAIN = -GameTime.time_to_zero(GameTime.hours(5))

var ENERGY_GAIN_SLEEPING = GameTime.time_to_zero(GameTime.hours(8))
var HUNGER_GAIN_COOKING = GameTime.time_to_zero(GameTime.minutes(30))
var BLADDER_GAIN_TOILET = GameTime.time_to_zero(GameTime.minutes(10))
var FUN_GAIN_PLAYING = GameTime.time_to_zero(GameTime.hours(4))

func _process(delta: float) -> void:
	drain_needs(delta)
	process_action_queue(delta)
	if Global.ai_enabled:
		ai_process()
	process_game_over_condition()
		
func process_action_queue(delta: float):
	if action_queue.size() > 0:
		var action = action_queue.front()
		var action_completed = false
		
		if action.type == Action.Type.MOVE:
			action_completed = move_to_target(delta, action)
		elif action.type == Action.Type.SLEEPING:
			action_completed = sleep(delta, action)
		elif action.type == Action.Type.COOKING:
			action_completed = cook(delta, action)
		elif action.type == Action.Type.TOILET:
			action_completed = toilet(delta, action)
		elif action.type == Action.Type.PLAYING:
			action_completed = play(delta, action)
		
		if action_completed:
			pop_action()


func move_to_target(delta: float, action: Action) -> bool:
	var scaled_delta = GameTime.in_game_minutes_delta(delta)
	var target_pos = action.target.global_transform.origin
	target_pos.y = 0
	global_transform.origin = global_transform.origin.move_toward(target_pos, speed * scaled_delta)
	return global_transform.origin.distance_to(target_pos) < 0.01


func sleep(delta, action) -> bool:
	energy += GameTime.scale(delta, ENERGY_GAIN_SLEEPING - ENERGY_DRAIN)
	if energy >= 1.0:
		energy = 1.0
		return true
	return false


func cook(delta, action) -> bool:
	hunger += GameTime.scale(delta, HUNGER_GAIN_COOKING - HUNGER_DRAIN)
	if hunger >= 1.0:
		hunger = 1.0
		return true
	return false


func toilet(delta, action) -> bool:
	bladder += GameTime.scale(delta, BLADDER_GAIN_TOILET - BLADDER_DRAIN)
	if bladder >= 1.0:
		bladder = 1.0
		return true
	return false


func play(delta, action) -> bool:
	fun += GameTime.scale(delta, FUN_GAIN_PLAYING - FUN_DRAIN)
	if fun >= 1.0:
		fun = 1.0
		return true
	return false


func drain_needs(delta: float) -> void:
	energy += GameTime.scale(delta, ENERGY_DRAIN)
	hunger += GameTime.scale(delta, HUNGER_DRAIN)
	bladder += GameTime.scale(delta, BLADDER_DRAIN)
	fun += GameTime.scale(delta, FUN_DRAIN)


func enqueue_action(action: Action):
	print("New action " + action.get_string())
	action_queue.append(action)
	action_queue_updated.emit()
	

func pop_action():
	action_queue.pop_front()
	action_queue_updated.emit()
	

func remove_action(action: Action):
	var i = action_queue.find(action)
	var following_action_to_erase: Action = null
	if i + 1 < action_queue.size():
		if action_queue[i + 1].type != Action.Type.MOVE:
			following_action_to_erase = action_queue[i + 1]
	action_queue.erase(action)
	if following_action_to_erase:
		action_queue.erase(following_action_to_erase)
	action_queue_updated.emit()


func interact_with_target(target: Node3D):
	enqueue_action(Action.new(Action.Type.MOVE, target))
	if target.name == "Bed":
		enqueue_action(Action.new(Action.Type.SLEEPING, null))
	elif target.name == "KitchenCounter":
		enqueue_action(Action.new(Action.Type.COOKING, null))
	elif target.name == "Toilet":
		enqueue_action(Action.new(Action.Type.TOILET, null))
	elif target.name == "Couch":
		enqueue_action(Action.new(Action.Type.RELAXING, null))
	elif target.name == "Bowling":
		enqueue_action(Action.new(Action.Type.PLAYING, null))


func ai_process():
	# Priority actions, override everything
	if hunger < 0.1:
		set_ai_priority_action(Action.new(Action.Type.COOKING, null))
	elif bladder < 0.1:
		set_ai_priority_action(Action.new(Action.Type.TOILET, null))
	elif energy < 0.1:
		set_ai_priority_action(Action.new(Action.Type.SLEEPING, null))
	elif fun < 0.1:
		set_ai_priority_action(Action.new(Action.Type.PLAYING, null))

	# Regular actions if not sleeping
	if not should_be_sleeping():
		if bladder < 0.3:
			set_ai_target_action(Action.new(Action.Type.TOILET, null))
		elif hunger < 0.5:
			set_ai_target_action(Action.new(Action.Type.COOKING, null))
		elif fun < 0.7:
			set_ai_target_action(Action.new(Action.Type.PLAYING, null))

	if should_be_sleeping():
		#if get_current_action_type() == Action.Type.PLAYING:
			#set_ai_priority_action(Action.new(Action.Type.SLEEPING, null))
		#else:
		set_ai_target_action(Action.new(Action.Type.SLEEPING, null))
	
	if action_queue.size() == 0:
		set_ai_target_action(Action.new(Action.Type.RELAXING, null))


func set_ai_target_action(action: Action):
	if not is_action_type_queued(action.type):
		var target = get_target_by_action_type(action.type)
		if target:
			enqueue_action(Action.new(Action.Type.MOVE, target))
		enqueue_action(action)
	
	# Relaxing is low priority
	if get_current_action_type() == Action.Type.RELAXING:
		remove_first_action_with_move()
		


func get_target_by_action_type(action_type: Action.Type) -> Node3D:
	var target: Node3D = null
	if action_type == Action.Type.SLEEPING:
		target = Global.bed
	elif action_type == Action.Type.COOKING:
		target = Global.kitchen_counter
	elif action_type == Action.Type.TOILET:
		target = Global.toilet
	elif action_type == Action.Type.PLAYING:
		target = Global.bowling
	elif action_type == Action.Type.RELAXING:
		target = Global.couch
	return target


func is_action_type_queued(action_type: Action.Type) -> bool:
	for action in action_queue:
		if action.type == action_type:
			return true
	return false
	
func set_ai_priority_action(action: Action):
	if not is_action_type_first(action.type):
		enqueue_priority_action(action)


func is_action_type_first(action_type: Action.Type) -> bool:
	return (action_queue.size() > 0 and \
		(action_queue[0].type == action_type or \
			(action_queue[0].type == Action.Type.MOVE and \
				action_queue[1].type == action_type)))


func enqueue_priority_action(action: Action):
	if not is_action_type_first(action.type):
		remove_all_actions_of_type(action.type)
		remove_first_action_with_move()
		action_queue.insert(0, action)
		var target = get_target_by_action_type(action.type)
		if target:
			action_queue.insert(0, Action.new(Action.Type.MOVE, target))


func remove_action_of_type(action_type: Action.Type):
	for a in action_queue:
		if a.type == action_type:
			var i = action_queue.find(a)
			action_queue.remove_at(i)
			if i > 0 and action_queue[i - 1].type == Action.Type.MOVE:
				action_queue.remove_at(i - 1)
			return true
	return false
	

func remove_all_actions_of_type(action_type: Action.Type):
	while remove_action_of_type(action_type):
		pass


func remove_first_action_with_move():
	if action_queue.size() > 0:
			if action_queue[0].type == Action.Type.MOVE:
				action_queue.remove_at(0)
				if action_queue.size() > 0:
					action_queue.remove_at(0)
			else:
				action_queue.remove_at(0)


func get_current_action_type():
	if action_queue.size() > 0:
		return action_queue[0].type
	else:
		return null
		

func should_be_sleeping():
	var current_hour = GameTime.get_current_hour()
	return current_hour > 0 and current_hour < 6


func process_game_over_condition():
	if energy < 0.0:
		Global.set_game_over("extreme yawniness")
	if hunger < 0.0:
		Global.set_game_over("insufficient nutrition experience")
	if bladder < 0.0:
		Global.set_game_over("bladder-induced embarrassment")
	if fun < 0.0:
		Global.set_game_over("time's molasses")


class Action:
	enum Type {
		IDLING,
		MOVE,
		COOKING,
		SLEEPING,
		TOILET,
		RELAXING,
		PLAYING
	}
	var type: Type
	var target: Node3D
	
	static func action_type_str(action_type: Type) -> String:
		return Type.keys()[action_type]

	func _init(type: Type, target: Node3D):
		self.type = type
		self.target = target

	func get_target_string(target: Node3D):
		return "%s %v" % [target.name, target.global_transform.origin]

	func get_string() -> String:
		var str = action_type_str(type)
		return str
