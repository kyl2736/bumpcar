extends Area2D

# 메인 씬에서 받을 수 있는 신호
signal player_entered(player)

func _ready() -> void:
	# 이 존에 뭔가 들어오면 호출되는 신호 연결
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Player만 피트스탑 대상으로 취급
	if body is Player:
		emit_signal("player_entered", body)
