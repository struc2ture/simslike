extends Node

const TIME_8AM = 480
const TIME_24H = 1440

const TIME_SCALE_PRESET_1 = 1.0
const TIME_SCALE_PRESET_2 = 2.0
const TIME_SCALE_PRESET_3 = 5.0
const TIME_SCALE_PRESET_4 = 20.0
const TIME_SCALE_PRESET_5 = 100.0

var in_game_minutes: float = TIME_8AM

@export var minutes_scale: float = TIME_SCALE_PRESET_1

func _process(delta: float) -> void:
	in_game_minutes += in_game_minutes_delta(delta)

func in_game_minutes_delta(delta: float) -> float:
	return delta * minutes_scale
	
func get_current_hour() -> int:
	return (int(in_game_minutes) % TIME_24H) / 60

func get_current_minute() -> int:
	return (int(in_game_minutes) % TIME_24H) % 60

func get_current_day() -> int:
	return int(in_game_minutes) / TIME_24H + 1
	
func get_current_time_scale() -> float:
	return minutes_scale

func set_current_time_scale(scale: float) -> void:
	minutes_scale = scale
	
func days(d: float) -> float:
	return d * TIME_24H
	
func hours(h: float) -> float:
	return h * 60
	
func minutes(m: float) -> float:
	return m

func time_to_zero(minutes: float) -> float:
	return 1 / minutes
	
func scale(delta: float, value: float) -> float:
	return in_game_minutes_delta(delta) * value
	
