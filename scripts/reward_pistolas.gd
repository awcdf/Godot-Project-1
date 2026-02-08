extends CanvasLayer

@export var star_scene: PackedScene = preload("res://scenes/estrela.tscn")
@export var star_count: int = 14
@export var auto_close_time: float = 3.0
@export var weapon_name: String = "Infernos"
@export var weapon_texture: Texture2D = preload("res://assets/sprits/pistolas.png")

@onready var overlay: ColorRect = $Overlay
@onready var stars_root: Node2D = $Stars
@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var name_label: Label = $NameLabel

var _was_paused: bool = false

func _ready() -> void:
	_was_paused = get_tree().paused
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	stars_root.process_mode = Node.PROCESS_MODE_ALWAYS
	weapon_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	name_label.process_mode = Node.PROCESS_MODE_ALWAYS

	weapon_sprite.texture = weapon_texture
	name_label.text = weapon_name
	_center_elements()
	_spawn_stars()
	_play_intro()

	if auto_close_time > 0.0:
		await get_tree().create_timer(auto_close_time, true).timeout
		queue_free()

func _exit_tree() -> void:
	if not _was_paused:
		get_tree().paused = false

func _spawn_stars() -> void:
	if not star_scene:
		return
	var view := get_viewport().get_visible_rect().size
	var rng := RandomNumberGenerator.new()
	var margin := 30.0
	var min_dist := 70.0
	var max_tries := 40
	var positions: Array[Vector2] = []
	var view_rect := Rect2(Vector2.ZERO, view)
	var weapon_rect := _get_weapon_exclusion_rect()
	for i in range(star_count):
		var placed := false
		for attempt in range(max_tries):
			var x := rng.randf_range(margin, max(margin, view.x - margin))
			var y := rng.randf_range(margin, max(margin, view.y - margin))
			var pos := Vector2(x, y)
			if not view_rect.has_point(pos):
				continue
			if weapon_rect.has_point(pos):
				continue
			if _too_close(pos, positions, min_dist):
				continue
			positions.append(pos)
			var star := star_scene.instantiate()
			stars_root.add_child(star)
			star.position = pos
			placed = true
			break
		if not placed:
			# If we can't place with spacing, relax slightly.
			min_dist = max(50.0, min_dist - 10.0)

func _center_elements() -> void:
	var view := get_viewport().get_visible_rect().size
	var center := view * 0.5
	weapon_sprite.position = center
	var weapon_size := Vector2.ZERO
	if weapon_sprite.texture:
		weapon_size = weapon_sprite.texture.get_size() * weapon_sprite.scale
	var label_size := Vector2(520, 60)
	name_label.size = label_size
	name_label.anchor_left = 0.0
	name_label.anchor_top = 0.0
	name_label.anchor_right = 0.0
	name_label.anchor_bottom = 0.0
	name_label.position = center + Vector2(-label_size.x * 0.5, weapon_size.y * 0.6)

func _get_weapon_exclusion_rect() -> Rect2:
	var view := get_viewport().get_visible_rect().size
	var center := view * 0.5
	var weapon_size := Vector2(320, 160)
	if weapon_sprite.texture:
		weapon_size = weapon_sprite.texture.get_size() * weapon_sprite.scale
	var label_size := Vector2(520, 60)
	var padding := 20.0
	var top_left := center - (weapon_size * 0.5) - Vector2(padding, padding)
	var bottom_right := center + (weapon_size * 0.5) + Vector2(padding, padding + label_size.y + 20.0)
	return Rect2(top_left, bottom_right - top_left)

func _too_close(pos: Vector2, existing: Array[Vector2], min_dist: float) -> bool:
	for p in existing:
		if p.distance_to(pos) < min_dist:
			return true
	return false

func _play_intro() -> void:
	weapon_sprite.scale = Vector2(0.2, 0.2)
	weapon_sprite.modulate.a = 0.0
	name_label.modulate.a = 0.0
	overlay.modulate.a = 0.0

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", 0.75, 0.2)
	tween.tween_property(weapon_sprite, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property(weapon_sprite, "scale", Vector2(1.0, 1.0), 0.35)
	tween.tween_property(name_label, "modulate:a", 1.0, 0.2)
