extends Node
class_name DialogueTextDisplay

enum SCROLLSTYLE {FIXED,DYNAMIC,WORD,SYLLABLE,INSTANT}

@export var dialogue_source : DialogueParser
@export var text_key : String = "text"
@export var translate : bool = false
@export var scroll_style : SCROLLSTYLE
@export var scroll_step : float = 1.0
@export var base_length : int = 64

@export_category("Syllable Scroll Settings")
@export var syllable_pause_length : float = 1.0
@export var syllable_splitter : String = "|"

var rTween : Tween
var parent : Node
var wait

signal scroll_finished()

func _ready():
	parent = get_parent()
	scroll_finished.connect(_on_scroll_finished)
	if dialogue_source != null:
		dialogue_source.line_read.connect(_on_source_line_read)
		dialogue_source.conversation_end.connect(_on_conversation_end)

func _on_source_line_read(index : int,lineData:Dictionary):
	if not parent is Label && not parent is RichTextLabel:
		return
	var rText = lineData.get(text_key)
	
	if DialogueServer.translate && translate: # use translation file's keys only if available
		if dialogue_source.parsed_translation is Array:
			if dialogue_source.parsed_translation.size() > 0: # only if the parser is holding a translation
				if dialogue_source.parsed_translation[index] is Dictionary: # only if the translation lines are set up as dict
					var rTranslation = dialogue_source.parsed_translation[index].get(text_key) #each translation's lines should sync up with the appropriate core conversation
					if rTranslation is String:
						rText = rTranslation #Sets the text to that found in the translation file
	
	if rText is String:
		if rTween != null:
			rTween.stop()
			rTween.kill()
		
		parent.set_visible_ratio(0)
		parent.text = rText
		
		match scroll_style :
			SCROLLSTYLE.FIXED:
				rTween = get_tree().create_tween()
				rTween.tween_property(parent,"visible_ratio",1.0,scroll_step)
				await rTween.finished
				scroll_finished.emit()
			SCROLLSTYLE.DYNAMIC:
				var scroll_time = scroll_step*(rText.length()/float(base_length))
				#scroll_time = clamp(scroll_time,0,scroll_step*2)
				rTween = get_tree().create_tween()
				rTween.tween_property(parent,"visible_ratio",1.0,scroll_time)
				await rTween.finished
				scroll_finished.emit()
			SCROLLSTYLE.SYLLABLE:
			# Syllable key is simply the text with a designated syllable_splitter character between individual syllables
				var rSyllable = lineData.get("syllables")
				
				if DialogueServer.translate && translate: #use translation file's syllables if available
					
					if dialogue_source.parsed_translation is Array:
						if dialogue_source.parsed_translation.size() > 0:
							if dialogue_source.parsed_translation[index] is Dictionary:
								var tSyllable = dialogue_source.parsed_translation[index].get("syllables")
								if tSyllable is String:
									rSyllable = tSyllable
				
				if rSyllable is String:
					var rSyl= rSyllable.split(syllable_splitter)
					parent.set_visible_characters(0) 
					if rSyl is PackedStringArray:
						var scroll_time = scroll_step*(rText.length()/float(base_length))
						var scroll_wait = scroll_time/(rSyl.size())
						for syl in rSyl:
							if parent.visible_characters == -1 : 
								break
							var waitTotal = scroll_wait
							wait = get_tree().create_timer(waitTotal)
							parent.visible_characters += syl.length()
							await wait.timeout
						scroll_finished.emit()
				parent.set_visible_characters(-1)
			SCROLLSTYLE.WORD :
				var rWords= rText.split(" ")
				parent.set_visible_characters(0) 
				if rWords is PackedStringArray:
					var scroll_time = scroll_step*(rText.length()/float(base_length))
					var scroll_wait = scroll_time/(rWords.size())
					for word in rWords:
						if parent.visible_characters == -1 : 
							break
						var waitTotal = scroll_wait
						wait = get_tree().create_timer(waitTotal)
						parent.visible_characters += word.length()
						await wait.timeout
						scroll_finished.emit()
				parent.set_visible_characters(-1)
				pass
			SCROLLSTYLE.INSTANT:
				rTween = get_tree().create_tween()
				rTween.tween_property(parent,"visible_ratio",1.0,0)
				await rTween.finished
				scroll_finished.emit()

func skip_scroll():
	if not parent is Label && not parent is RichTextLabel:
		return
	if rTween is Tween:
		rTween.finished.emit()
		rTween.kill()
	parent.set_visible_characters(-1)
	scroll_finished.emit()
	
func _on_conversation_end():
	rTween = get_tree().create_tween()
	rTween.tween_property(parent,"visible_ratio",0,0)

func _on_scroll_finished():
	pass
