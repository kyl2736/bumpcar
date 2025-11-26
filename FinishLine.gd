extends Area2D

signal player_crossed(player)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player_1 or body is Player_2:
		if body.can_count_lap == false:
			return  

		body.can_count_lap = false  
		emit_signal("player_crossed", body)
