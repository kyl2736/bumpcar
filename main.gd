extends Node2D

func _ready():
	var pit = $PitstopZone
	pit.player_entered.connect(_on_player_enter_pitstop)

func _on_player_enter_pitstop(player):
	var pit_scene = preload("res://UI/PitstopMinigame.tscn")
	var pit_ui: Minigame = pit_scene.instantiate()
	
	pit_ui.finished.connect(func(success, upg):
		if success and upg:
			player.stats[upg["key"]] += upg["delta"]
	)
	$UI.add_child(pit_ui)
