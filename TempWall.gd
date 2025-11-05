# TempWall.gd
extends StaticBody2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(queue_free)
	timer.start()
