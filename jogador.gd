extends CharacterBody2D

const VELOCIDADE = 100.0
const PULO = -600.0

# Pega a gravidade padrão do projeto (assim funciona na Terra ou na Lua se você mudar depois)
var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += gravidade * delta

	# Pular (Use a Barra de Espaço)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = PULO

	# Movimento (Setinhas do teclado)
	var direcao = Input.get_axis("ui_left", "ui_right")
	if direcao:
		velocity.x = direcao * VELOCIDADE
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE)

	move_and_slide()
