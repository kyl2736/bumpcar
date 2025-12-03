# Player.gd
extends CharacterBody2D
class_name Player_1

@export var player_id := 1
@export var gauge_max := 100.0
@export var wall_kick_restitution := 1.0   # 벽 법선 성분 보존 후 반전 계수
@export var parallel_boost_factor := 0.25  # 벽과 평행 성분에 더해줄 비율
@export var gauge_per_hit := 12.0          # 벽 부딪힘 시 게이지 증가량
@export var item_icon_map := {}            # ItemType:int -> Texture (에디터에서 연결)



var stats: Dictionary = GameDefs.BASES.duplicate()
var input_dir: Vector2 = Vector2.ZERO
var gauge: float = 0.0
var current_item: int = GameDefs.ItemType.NONE
var laps := 0
var last_cross_time := -1.0
var finished := false
var can_count_lap := false

var invincible := false
var magnet_on := false
var boost_on := false

@onready var invincible_timer: Timer = $InvincibleTimer
@onready var magnet_timer: Timer = $MagnetTimer
@onready var boost_timer: Timer = $BoostTimer
@onready var item_holder = $ItemHolder

var hud
func _ready() -> void:
	hud = get_node("/root/Main/UI/HUD_Player3")
	print("Player1 HUD =", hud)
	invincible_timer.timeout.connect(_on_invincible_done)
	magnet_timer.timeout.connect(_on_magnet_done)
	boost_timer.timeout.connect(_on_boost_done)
	update_hud()


func _physics_process(delta: float) -> void:
	_read_input()
	_apply_motor(delta)
	_move_and_collide_with_wallkick(delta)

func _read_input() -> void:
	input_dir = Vector2(
		Input.get_action_strength("1move_right") - Input.get_action_strength("1move_left"),
		Input.get_action_strength("1move_down") - Input.get_action_strength("1move_up")
	).normalized()

	if Input.is_action_just_pressed("special_use"):
		_use_item()

func _apply_motor(delta: float) -> void:
	var target_v = input_dir * stats["max_speed"]
	var to_target = target_v - velocity
	var ax = stats["accel"] if to_target.length() > 0 else stats["decel"]
	
	var step = ax * delta
	if to_target.length() > step:
		velocity += to_target.normalized() * step
	else:
		velocity = target_v

	if boost_on and velocity.length() > stats["boost_cap"]:
		velocity = velocity.normalized() * stats["boost_cap"]

	if input_dir != Vector2.ZERO:
		var lerp_amount = clamp(stats["handling"] * delta * 0.1, 0.0, 1.0)
		velocity = velocity.lerp(input_dir * velocity.length(), lerp_amount)

func _move_and_collide_with_wallkick(delta: float) -> void:
	var motion := velocity * delta
	var collision := move_and_collide(motion)
	if collision:
		_on_hit_wall(collision.get_normal())
	else:
		global_position += motion

func _on_hit_wall(normal: Vector2) -> void:
	if invincible:
		return

	# --- 벽 부딪힘 시 자동 wall kick ---
	var n := normal.normalized()
	var v := velocity
	var v_n := v.project(n)
	var v_t := v - v_n

	var boosted := (-v_n * wall_kick_restitution) + (v_t * (1.0 + parallel_boost_factor))
	velocity = boosted

	# 속도 상한 및 감쇠 적용
	var target_speed: float = min(stats["boost_cap"], velocity.length() + 120.0)
	velocity = velocity.normalized() * target_speed
	velocity *= (0.9 + 0.1 * stats["mass"])

	# 부딪힘 게이지 상승
	_add_gauge(gauge_per_hit)

	# 카메라 흔들림 효과 (카메라가 있다면)
	get_viewport().get_camera_2d().start_shake(6.0)

func _add_gauge(amount: float) -> void:
	gauge = clamp(gauge + amount, 0.0, gauge_max)
	update_hud()
	if gauge >= gauge_max and current_item == GameDefs.ItemType.NONE:
		_roll_item()
		gauge = 0.0
		update_hud()

func _roll_item() -> void:
	var pool = GameDefs.ITEM_POOL
	current_item = pool[randi() % pool.size()]
	if hud:
		hud.set_item_icon(_icon_for(current_item))

func _use_item() -> void:
	if current_item == GameDefs.ItemType.NONE:
		return
	match current_item:
		GameDefs.ItemType.SHIELD:
			_invincible_start(GameDefs.ITEM_DURATIONS[GameDefs.ItemType.SHIELD])
		GameDefs.ItemType.MAGNET:
			_magnet_start(GameDefs.ITEM_DURATIONS[GameDefs.ItemType.MAGNET])
		GameDefs.ItemType.BOOST:
			_boost_start(GameDefs.ITEM_DURATIONS[GameDefs.ItemType.BOOST])
		GameDefs.ItemType.HOOK:
			_fire_hook()
		GameDefs.ItemType.WALL_SUMMON:
			_spawn_temp_wall()
	current_item = GameDefs.ItemType.NONE
	if hud:
		hud.set_item_icon(null)

func _invincible_start(sec: float) -> void:
	invincible = true
	invincible_timer.start(sec)
	modulate = Color(1,1,1,0.6)

func _on_invincible_done() -> void:
	invincible = false
	modulate = Color(1,1,1,1)

func _magnet_start(sec: float) -> void:
	magnet_on = true
	magnet_timer.start(sec)

func _on_magnet_done() -> void:
	magnet_on = false

func _boost_start(sec: float) -> void:
	boost_on = true
	boost_timer.start(sec)

func _on_boost_done() -> void:
	boost_on = false

func _fire_hook() -> void:
	var space = get_world_2d().direct_space_state
	var to = global_position + velocity.normalized() * 300.0
	var query = PhysicsRayQueryParameters2D.create(global_position, to)
	var res = space.intersect_ray(query)
	if res and res.has("position"):
		var hit_pos: Vector2 = res["position"]
		var dir = (hit_pos - global_position)
		velocity = dir.normalized() * max(velocity.length(), 600.0)

func _spawn_temp_wall() -> void:
	var wall_scene: PackedScene = preload("res://TempWall.tscn")
	var wall := wall_scene.instantiate()
	get_tree().current_scene.add_child(wall)
	wall.global_position = global_position

func _icon_for(item: int) -> Texture2D:
	return item_icon_map.get(item, null)

func update_hud() -> void:
	if hud:
		hud.set_gauge(gauge / gauge_max)
