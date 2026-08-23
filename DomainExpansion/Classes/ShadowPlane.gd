extends Node2D
class_name ShadowSurface2D

@export var shadow_color:Color = Color(Color.DARK_SLATE_GRAY*1.2,1.0)
@export var shadows_of:Array[Node2D] = []

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for n in shadows_of:
		draw_set_transform(global_position,n.rotation,n.scale)
		if "draw_shadow" in n:
			n.draw_shadow(shadow_color,self)
