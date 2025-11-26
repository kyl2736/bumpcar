extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player_1 or body is Player_2:
		body.can_count_lap = true  
