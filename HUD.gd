# HUD.gd
extends Control
class_name HUD

@onready var gauge_bar : ProgressBar = $Gauge
@onready var item_slot : TextureRect = $ItemSlot

func _ready() -> void:
	add_to_group("HUD")

func set_gauge(ratio: float) -> void:
	gauge_bar.value = clamp(ratio * gauge_bar.max_value, 0.0, gauge_bar.max_value)

func set_item_icon(tex: Texture2D) -> void:
	item_slot.texture = tex

# 예: Main.gd (또는 HUD.gd 안에서)
func open_pitstop_for(player) -> void:
	var scene: PackedScene
	var p := scene.instantiate()
	$UI/HUD.add_child(p)
	p.finished.connect(func(success: bool, upg: Dictionary):
		if success and upg:
			player.stats[upg["key"]] += upg["delta"]
	)
