extends CharacterBody2D

const VELOCIDADE = 100.0
const PULO = -600.0
const PULO_2X_FATOR = 0.5
const MAX_PULOS = 2

# Pega a gravidade padrão do projeto (assim funciona na Terra ou na Lua se você mudar depois)
var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")
var _pulos_usados: int = 0

func _ready() -> void:
	var spawn := get_tree().current_scene.get_node_or_null("SpawnPoint")
	if spawn:
		global_position = spawn.global_position

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
	var direcao = Input.get_axis("ui_left", "ui_right")
	if direcao:
		velocity.x = direcao * VELOCIDADE
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	move_and_slide()
