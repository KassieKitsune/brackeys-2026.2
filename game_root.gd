extends Node

@onready var level_root: Node2D = $WorldRoot/LevelRoot
@onready var entity_root: Node2D = $WorldRoot/EntityRoot
@onready var effect_root: Node2D = $WorldRoot/EffectRoot

@onready var hud_root: Control = $HudLayer/HudRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugLayer/DebugRoot


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build() :
		debug_root.visible = true
		debug_root.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		debug_root.visible = false
		debug_root.process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
