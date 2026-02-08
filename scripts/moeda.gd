extends Area2D

@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready():
	Global.register_coin()
	body_entered.connect(_on_body_entered)
	if anim:
		anim.play("spin")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		Global.add_coin(1)
		Global.play_coin_sfx()
		queue_free()
	
"res://assets/sprits/icon.svg"
