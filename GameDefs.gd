# GameDefs.gd (Godot 4, GDScript)
extends Node

enum ItemType { NONE, SHIELD, MAGNET, BOOST, HOOK, WALL_SUMMON }

const ITEM_POOL := [
	ItemType.SHIELD,
	ItemType.MAGNET,
	ItemType.BOOST,
	ItemType.HOOK,
	ItemType.WALL_SUMMON,
]

# 아이템/업그레이드 수치
const ITEM_DURATIONS := {
	ItemType.SHIELD: 3.0,
	ItemType.MAGNET: 5.0,
	ItemType.BOOST: 2.0,
	ItemType.HOOK: 0.0,         # 즉시 사용형
	ItemType.WALL_SUMMON: 0.0   # 즉시 사용형
}

const BASES := {
	"max_speed": 1000.0,
	"accel": 1800.0,
	"decel": 2200.0,
	"handling": 9.0,    # 회전/조향 보정
	"mass": 1.0,        # 반탄(튕김) 계산에서 사용
	"boost_cap": 800.0, # 부스트 상한
}

# 피트스탑 업그레이드
const UPGRADE_TABLE := [
	{"key":"max_speed", "delta": +60.0, "label":"최대속도 ↑"},
	{"key":"handling",  "delta": +1.5,  "label":"핸들링 ↑"},
	{"key":"mass",      "delta": +0.2,  "label":"차량 무게 ↑(튕김 감소)"},
	{"key":"mass",      "delta": -0.2,  "label":"차량 무게 ↓(더 많이 튕김)"},
]
