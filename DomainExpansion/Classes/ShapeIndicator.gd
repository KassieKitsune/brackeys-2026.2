extends Node2D
class_name DrawShape

enum DRAW {CIRCLE,RECTANGLE,CAPSULE,SEGMENT}
var draw_mode : DRAW

@export var shape : Shape2D
@export var color : Color

@onready var parent = get_parent()

func _ready():
	if "shape" in parent :
		shape = parent.shape
	if "debug_color" in parent :
		color = parent.debug_color
	
	if shape is CircleShape2D:
		draw_mode = DRAW.CIRCLE
	elif shape is RectangleShape2D:
		draw_mode = DRAW.RECTANGLE
	elif shape is CapsuleShape2D:
		draw_mode = DRAW.CAPSULE
	elif shape is SegmentShape2D:
		draw_mode = DRAW.SEGMENT
	pass # Replace with function body.

func _draw():
	match draw_mode:
		DRAW.CIRCLE:
			draw_circle(Vector2.ZERO,shape.radius,color)
		DRAW.RECTANGLE:
			draw_rect(Rect2(-shape.size/2,shape.size),color)
		DRAW.CAPSULE:
			draw_rect(Rect2(Vector2(-shape.radius,-shape.height/2+shape.radius),Vector2(shape.radius*2,shape.height-shape.radius*2)),color)
			draw_circle(Vector2(0,-shape.height/2+shape.radius),shape.radius,color)
			draw_circle(Vector2(0,+shape.height/2-shape.radius),shape.radius,color)
		DRAW.SEGMENT:
			draw_line(shape.a,shape.b,color)
	pass
