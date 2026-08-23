extends TextureRect
class_name DialogueBackground

@onready var dialogue_source : DialogueParser = %DialogueParser

func _ready():
	if dialogue_source != null:
		dialogue_source.line_read.connect(_on_line_read)

func _on_line_read(index,lineData:Dictionary) :
	var line_background = lineData.get("background")
	if line_background != null:
		if texture != null:
			var nDupe = self.duplicate()
			nDupe.self_modulate = Color(1.0,1.0,1.0,0.0)
			add_sibling(nDupe)
			var fTween = get_tree().create_tween()
			fTween.set_parallel()
			fTween.tween_property(self,"self_modulate",Color(0.0,0.0,0.0,0.0),0.5)
			fTween.tween_property(nDupe,"self_modulate",Color(1.0,1.0,1.0,1.0),0.5)
			if line_background is String:
				nDupe.texture = DialogueServer.request_background(line_background)
		else : texture = DialogueServer.request_background(line_background)
