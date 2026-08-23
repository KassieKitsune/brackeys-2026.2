extends Node
class_name DialogueAudio

@onready var dialogue_source : DialogueParser = %DialogueParser

func _ready():
	if dialogue_source != null :
		dialogue_source.line_read.connect(_on_line_read)
	pass

func _on_line_read(index:int,lineData:Dictionary):
	var line_sfx = lineData.get("soundfx")
	if line_sfx is String:
		SoundManager.play_sound(SoundManager.request_sound(line_sfx))
	var line_music = lineData.get("music")
	if line_music is String:
		SoundManager.change_music(SoundManager.request_music(line_music))
