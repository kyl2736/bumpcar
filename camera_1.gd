# FollowCamera.gd
extends Camera2D
class_name FollowCamera

@export var target_path: NodePath                # 따라갈 대상 (Player)
@export var follow_speed := 6.0                  # 따라가는 속도
@export var look_ahead_distance := 120.0         # 속도 기반 카메라 선행 거리
@export var shake_decay := 6.0                   # 흔들림 감소 속도
@export var shake_strength := 0.0                # 현재 흔들림 강도

var _target: Node = null
var _shake_offset := Vector2.ZERO
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	zoom=Vector2(0.4,0.4)
	if target_path != NodePath(""):
		_target = get_node(target_path)
	else:
		push_warning("FollowCamera: target_path가 지정되지 않았습니다.")

	randomize()

func _process(delta: float) -> void:
	if _target:
		_update_follow(delta)
	_update_shake(delta)

func _update_follow(delta: float) -> void:
	var player_pos: Vector2 = _target.global_position
	var player_vel: Vector2 = _target.velocity if _target.has_variable("velocity") else Vector2.ZERO
	# 속도 방향으로 선행
	var ahead_pos := player_pos + player_vel.normalized() * look_ahead_distance
	# 부드럽게 따라가기
	global_position = global_position.lerp(ahead_pos + _shake_offset, follow_speed * delta)

func _update_shake(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = max(shake_strength - shake_decay * delta, 0.0)
		_shake_offset = Vector2(
			_rng.randf_range(-1, 1),
			_rng.randf_range(-1, 1)
		) * shake_strength
	else:
		_shake_offset = Vector2.ZERO

func start_shake(amount: float) -> void:
	# 외부에서 호출해 카메라 흔들기 시작 (예: 벽 부딪힘, 부스트 시)
	shake_strength = amount
