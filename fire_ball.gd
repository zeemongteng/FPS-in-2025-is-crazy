extends Area3D
class_name Fireball

@export var speed: float = 20.0
var direction: Vector3 = Vector3.ZERO
@export var hitbox : Hitbox

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	position += direction * speed * delta
	
	rotation.x += .1
	rotation.y += .1
	rotation.z += .1

func disappear():
	queue_free()
