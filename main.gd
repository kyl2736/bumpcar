extends Node2D

@export var total_laps := 3   # set how many laps needed to win

@onready var p1 := $Player1
@onready var p2 := $Player2
@onready var finish := $Track/FinishLine

func _ready():
	var pit = $PitstopZone
	pit.player_entered.connect(_on_player_enter_pitstop)

	finish.player_crossed.connect(_on_player_crossed_finish)


func _on_player_enter_pitstop(player):
	var pit_scene = preload("res://UI/PitstopMinigame.tscn")
	var pit_ui: Minigame = pit_scene.instantiate()
	
	pit_ui.finished.connect(func(success, upg):
		if success and upg:
			player.stats[upg["key"]] += upg["delta"]
	)
	$UI.add_child(pit_ui)

func _on_player_crossed_finish(player):
	if player.finished:
		return  # already won or counted

	var time_now := Time.get_ticks_msec()

	# Prevent double-counting from multiple collision frames
	if time_now - player.last_cross_time < 500:
		return
	player.last_cross_time = time_now

	player.laps += 1
	print("Player", player.player_id, "lap:", player.laps)

	# Check win condition
	if player.laps >= total_laps:
		player.finished = true
		_on_player_wins(player)
		
func _on_player_wins(player):
	print("\n=== WINNER: PLAYER", player.player_id, "===\n")

	# freeze both players
	p1.velocity = Vector2.ZERO
	p2.velocity = Vector2.ZERO

	p1.set_physics_process(false)
	p2.set_physics_process(false)

	# show a UI announcement
	_show_winner_ui(player.player_id)
	
func _show_winner_ui(id):
	var label := $UI/WinnerLabel
	label.text = "PLAYER %d WINS!" % id
	label.visible = true
