extends Area3D
class_name Fireball

@export var speed: float = 20.0
var direction: Vector3 = Vector3.ZERO
@export var hitbox : Hitbox
@onready var collider : CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	position += direction * speed * delta
	
	rotation.x += .1
	rotation.y += .1
	rotation.z += .1

func disappear():
	queue_free()

func flipped():
	call_deferred("_enable_hitbox2")
	
func _enable_hitbox2():
	var shape = get_node("Hitbox2/CollisionShape3D")
	shape.disabled = false
