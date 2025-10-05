extends Area3D
class_name Fireball

@export var speed: float = 20.0
var direction: Vector3 = Vector3.ZERO


func _process(delta: float) -> void:
	if direction == Vector3.ZERO:
		return
	position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body.has_method("on_damaged"):
		var attack = Attack.new()
		attack.damage = 10
		body.on_damaged(attack)
		queue_free()
	elif not body.is_in_group("Enemy"):
		# Fireball hits any solid object
		queue_free()
