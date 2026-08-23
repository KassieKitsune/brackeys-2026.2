extends Control
class_name DialogueInput
var listening: bool = true
var wTime : SceneTreeTimer

@export var auto: bool = false
@export var auto_wait : float = 1
@export var min_wait : float = 5
@export var mouse_input : bool = false
@export var continue_input : String = "ui_accept"
@export var monitor_displays : Array[DialogueTextDisplay]

@onready var dialogue_source : DialogueParser = %DialogueParser

func _process(delta):
	if wTime != null:
		listening = true
		for disp in monitor_displays:
			var par = disp.parent
			if "visible_characters" in par:
				if par.visible_characters != -1:
					listening = false
					break
	
func _unhandled_input(event: InputEvent) -> void:
	if !auto:
		if dialogue_source != null :
			if Input.is_action_just_pressed("ui_accept"):
				progress_dialogue()

func _gui_input(event: InputEvent) -> void:
	if !auto:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
				progress_dialogue()

func progress_dialogue():
	if wTime != null && listening:
		if !dialogue_source.paused:
			dialogue_source.read()
	else:
		for disp in monitor_displays:
			disp.skip_scroll()
	if wTime == null:
		wTime = get_tree().create_timer(min_wait)
		await wTime.timeout
		listening = true

func _on_dialogue_text_sampler_scroll_finished():
	if auto: 
		await get_tree().create_timer(auto_wait).timeout
		if !dialogue_source.paused:
			progress_dialogue()
	pass # Replace with function body.


func _on_auto_toggle_toggled(toggled_on):
	auto = toggled_on
	if toggled_on:
		progress_dialogue()
		pass
	pass # Replace with function body.

func _on_dialogue_parser_line_read(line, linedata:Dictionary):
	if auto :
		for disp in monitor_displays:
			if linedata.get(disp.text_key) == null && !dialogue_source.paused:
				await get_tree().create_timer(auto_wait).timeout
				if dialogue_source.reading == line :
					progress_dialogue()
				break
	pass # Replace with function body.
