extends CharacterBody2D

const VELOCIDADE = 100.0
const PULO = -600.0
const PULO_2X_FATOR = 0.5
const MAX_PULOS = 2

# Pega a gravidade padrão do projeto (assim funciona na Terra ou na Lua se você mudar depois)
var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")
var _pulos_usados: int = 0
@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	Global.ensure_run_started()
	var spawn := get_tree().current_scene.get_node_or_null("SpawnPoint")
	if spawn:
		global_position = spawn.global_position
	var cam: Camera2D = get_node_or_null("Camera2D")
	if cam:
		var view_size := get_viewport().get_visible_rect().size
		cam.position.y = -view_size.y * 0.3

func _physics_process(delta):
	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += gravidade * delta
	else:
		_pulos_usados = 0

	# Pular (Use a Barra de Espaço)
	if Input.is_action_just_pressed("ui_accept") and _pulos_usados < MAX_PULOS:
		if _pulos_usados == 0:
			velocity.y = PULO
		else:
			velocity.y = PULO * PULO_2X_FATOR
		_pulos_usados += 1
		Global.play_jump_sfx()

	# Movimento (Setinhas do teclado)
	var speed_mult := 1.0
	if Input.is_key_pressed(KEY_X):
		speed_mult = 10.0
	var direcao = Input.get_axis("ui_left", "ui_right")
	if direcao:
		velocity.x = direcao * VELOCIDADE * speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	if anim:
		if not is_on_floor():
			if velocity.y < 0.0:
				anim.play("jump_start")
			elif velocity.y > 0.0:
				anim.play("jump_fall")
			else:
				anim.play("jump_mid")
		elif abs(velocity.x) > 0.1:
			anim.play("run")
		else:
			anim.play("idle")
		if velocity.x < -0.1:
			anim.flip_h = true
		elif velocity.x > 0.1:
			anim.flip_h = false

	move_and_slide()
