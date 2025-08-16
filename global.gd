extends Node

var player: Player

var bed: Node3D
var kitchen_counter: Node3D
var toilet: Node3D
var couch: Node3D
var bowling: Node3D

var ai_enabled = false
var game_over = false
var game_over_reason: String

func _ready():
	player = get_node("/root/MainScene/Player")
	bed = get_node("/root/MainScene/Navigation/Bed")
	kitchen_counter = get_node("/root/MainScene/Navigation/KitchenCounter")
	toilet = get_node("/root/MainScene/Navigation/Toilet")
	couch = get_node("/root/MainScene/Navigation/Couch")
	bowling = get_node("/root/MainScene/Navigation/Bowling")
	

func set_game_over(reason: String):
	get_tree().paused = true
	game_over = true
	game_over_reason = reason
