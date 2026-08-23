extends CanvasLayer

@onready var anim = $AnimationPlayer

signal scene_changed

func _process(delta):
	if Input.is_action_just_pressed("debug_reset"):
		reset_scene()
	pass

func blink(animation : String = "Fade",animation2 : String = "Fade"):
	anim.play(animation)
	await anim.animation_finished
	if animation == animation2 :
		anim.play_backwards(animation)
	else :
		anim.play(animation2)
	pass

func to_scene(scene : PackedScene,animation : String = "Fade",animation2 : String = "Fade"):
	emit_signal("scene_changed")
	anim.play(animation)
	await anim.animation_finished
	get_tree().change_scene_to_packed(scene)
	if animation == animation2 :
		anim.play_backwards(animation)
	else :
		anim.play(animation2)
	pass
	
func to_scene_path(scene : String,animation : String = "Fade",animation2 : String = "Fade"):
	emit_signal("scene_changed")
	anim.play(animation)
	await anim.animation_finished
	get_tree().change_scene_to_file(scene)
	if animation == animation2 :
		anim.play_backwards(animation)
	else :
		anim.play(animation2)
	pass
	
func reset_scene(animation : String = "Fade",animation2 : String = "Fade"):
	get_tree().paused = true
	emit_signal("scene_changed")
	anim.play(animation)
	await anim.animation_finished
	get_tree().paused = false
	get_tree().reload_current_scene()
	if animation == animation2 :
		anim.play_backwards(animation)
	else :
		anim.play(animation2)
