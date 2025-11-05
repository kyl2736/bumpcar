# PitstopMinigame.gd
extends Control

class_name PitstopMinigame

const GameDefs = preload("res://scripts/GameDefs.gd")
signal finished(success: bool, chosen_upgrade: Dictionary)

@export var speed := 520.0
@export var window_width := 120.0

var dir := 1
var success := false
var ended := false

@onready var bar := $Bar
@onready var win := $Window
@onready var target := $Target
@onready var result := $Result
@onready var list := $UpgradeList

func _ready() -> void:
	result.text = "타이밍에 맞춰 [Enter]"
	_build_upgrades()
	set_process(true)

func _process(delta: float) -> void:
	if ended: return
	var min_x = bar.position.x
	var max_x = bar.position.x + bar.size.x - target.size.x
	var pos = target.position

	pos.x += dir * speed * delta
	if pos.x <= min_x:
		pos.x = min_x; dir = 1
	elif pos.x >= max_x:
		pos.x = max_x; dir = -1
	target.position = pos

	if Input.is_action_just_pressed("pit_confirm"):
		_check_hit()

func _check_hit() -> void:
	var t_left = target.global_position.x
	var t_right = t_left + target.size.x
	var w_left = win.global_position.x
	var w_right = w_left + window_width
	if (t_left >= w_left and t_right <= w_right):
		success = true
		result.text = "성공! 업그레이드를 고르세요."
		list.visible = true
	else:
		success = false
		result.text = "실패! 다음 기회에…"
		_finish({})

func _build_upgrades() -> void:
	list.visible = false
	list.clear()
	var picks := []
	randomize()
	while picks.size() < 3:
		var c = GameDefs.UPGRADE_TABLE[randi() % GameDefs.UPGRADE_TABLE.size()]
		if not picks.has(c):
			picks.append(c)
	for o in picks:
		var b := Button.new()
		b.text = o["label"]
		b.pressed.connect(func():
			_finish(o)
		)
		list.add_child(b)


func _finish(choice: Dictionary) -> void:
	ended = true
	visible = false
	emit_signal("finished", success, choice)
	queue_free()
