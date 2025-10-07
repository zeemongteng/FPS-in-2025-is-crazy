extends ProgressBar

@export var stamina_node: Stamina  

func _ready() -> void:
	max_value = stamina_node.max_stamina
	value = stamina_node.stamina
	stamina_node.stamina_gained.connect(_on_stamina_changed)

func _process(_delta: float) -> void:
	value = stamina_node.stamina

func _on_stamina_changed(new_stamina: float) -> void:
	value = new_stamina
