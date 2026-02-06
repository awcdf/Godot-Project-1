extends Area2D

@export var speed: float = 80.0

@onready var point_a: Marker2D = $PointA
@onready var point_b: Marker2D = $PointB

var _target: Vector2
var _point_a_pos: Vector2
var _point_b_pos: Vector2

func _ready() -> void:
	if not point_a or not point_b:
		push_warning("PointA ou PointB nao encontrados na cena do inimigo.")
		return

	# Cacheia as posicoes globais porque os Marker2D sao filhos
	# e se movem junto com o inimigo.
	_point_a_pos = point_a.global_position
	_point_b_pos = point_b.global_position
	_target = _point_b_pos
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not point_a or not point_b:
		return

	global_position = global_position.move_toward(_target, speed * delta)
	if global_position.distance_to(_target) <= 1.0:
		_target = _point_a_pos if _target == _point_b_pos else _point_b_pos

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().paused = false
		Global.play_death_sfx()
		Global.reset()
		get_tree().reload_current_scene()
