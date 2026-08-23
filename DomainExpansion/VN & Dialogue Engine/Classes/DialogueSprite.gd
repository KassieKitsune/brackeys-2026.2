extends AnimatedSprite2D
class_name DialogueSprite

@onready var dialogue_source : DialogueParser = %DialogueParser

func change_expression(expression : String):
	if !sprite_frames.has_animation(expression):
		add_expression(expression,[])
		pass
	play(expression)
	pass

func add_expression(expression,frames:Array[Texture2D]):
	if !sprite_frames.has_animation(expression):
		sprite_frames.add_animation(expression)
	for frame in frames:
		sprite_frames.add_frame(expression,frame)
