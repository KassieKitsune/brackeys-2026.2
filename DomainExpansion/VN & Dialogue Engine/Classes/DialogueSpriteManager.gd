extends ReferenceRect
class_name DialogueSpriteManager

@export var tween_length : float = 0.5
@export var sprite_scale : Vector2 = Vector2(1.0,1.0)
@export var sprite_origin : Vector2 = Vector2(0.5,0.0)
@export var unfocused_modulate : Color = Color(0.8,0.8,0.8,1.0)
var sprites = {}

@onready var screen_rect = get_viewport_rect()

@onready var dialogue_source : DialogueParser = %DialogueParser
func _ready():
	if dialogue_source != null :
		dialogue_source.line_read.connect(_on_line_read)
		dialogue_source.conversation_end.connect(_on_conversation_end)
	pass # Replace with function body.

func _on_conversation_end():
	for sprite in sprites.keys():
		sprite_exit(sprite)

func _on_line_read(line:int,linedata:Dictionary):
	var line_character = linedata.get("character")
	
	if line_character != null:
		var line_expression = linedata.get("expression")
		var line_h_position = linedata.get("h_position")
		var line_v_position = linedata.get("v_position")
		var line_z_position = linedata.get("z_position")
		var line_flip = linedata.get("flip")
		var line_tween = linedata.get("tween_length")
		var spr_position = sprite_origin
		var spr_tween = tween_length
		var spr_z = 0
		
		if line_tween is float :
			spr_tween = line_tween
		
		if line_expression == null:
			line_expression = CharacterServer.default_expression
		
		if line_h_position != null:
			spr_position.x = line_h_position
		if line_v_position != null:
			spr_position.y = line_v_position
		if line_z_position != null:
			spr_z = line_z_position
		
		if !sprites.keys().has(line_character):
			create_sprite(line_character,CharacterServer.default_expression,spr_position,spr_z)
		elif !sprites[line_character].visible:
			sprite_reenter(line_character)
			
		if line_h_position != null || line_v_position != null:
			move_sprite(line_character,spr_position,spr_tween)
		if line_z_position != null:
			sprites[line_character].z_index = line_z_position
		if line_expression != null:
			if !sprites[line_character].sprite_frames.has_animation(line_expression):
				var expression_frames = CharacterServer.request_portrait(line_character,line_expression,true)
				if expression_frames == []:
					expression_frames = CharacterServer.request_portrait(line_character,CharacterServer.default_expression,true)
				sprites[line_character].add_expression(line_expression,expression_frames)
			sprites[line_character].change_expression(line_expression)
		if line_flip != null :
			
			flip_sprite(line_character)
		focus_sprite(line_character)
	
	var line_exit = linedata.get("characters_exit") 
	if line_exit != null :
		for char in line_exit :
			sprite_exit(char)
			print(line_exit)

func create_sprite(character : String,expression : String = CharacterServer.default_expression, sprite_position : Vector2 = Vector2(0.5,0.5),sprite_depth : int = 0):
	var frames = CharacterServer.request_portrait(character,expression,true)
	var absCoord = size*sprite_position+Vector2(0,size.y)
	var sprite = DialogueSprite.new()
	
	sprite.dialogue_source = dialogue_source
	sprite.sprite_frames = SpriteFrames.new()
	if !sprite.sprite_frames.has_animation(expression):
		var expression_frames = CharacterServer.request_portrait(character,expression,true)
		if expression_frames == []:
			expression_frames = CharacterServer.request_portrait(character,CharacterServer.default_expression,true)
		sprite.add_expression(expression,expression_frames)
	sprite.change_expression(expression)
	sprite.position = absCoord
	sprite.self_modulate = Color(1.0,1.0,1.0,0.0)
	sprite.scale = sprite_scale
	sprite.z_index = sprite_depth
	sprites[character] = sprite
	add_child(sprite)
	print(sprite.position)
	var modTween = get_tree().create_tween()
	modTween.tween_property(sprite,"self_modulate",Color(1.0,1.0,1.0,1.0),tween_length)
	await modTween.finished
	#equalize_distance()
	pass

func focus_sprite(sprite):
	var modTween = get_tree().create_tween()
	modTween.set_parallel()
	for sp in sprites.keys():
		if sp == sprite :
			modTween.tween_property(sprites[sp],"self_modulate",Color(1.0,1.0,1.0,1.0),tween_length)
		else :
			modTween.tween_property(sprites[sp],"self_modulate",unfocused_modulate,tween_length)
		pass
	pass

func equalize_distance():
	for sp in sprites.keys():
		
		pass
	pass

func move_sprite(sprite,sprite_position,duration:float = tween_length):
	var moveTween = get_tree().create_tween()
	var absCoord = size*sprite_position
	moveTween.tween_property(sprites[sprite],"position",absCoord,duration)
	await moveTween.finished

func sprite_exit(sprite):
	if !sprites.keys().has(sprite) :
		return
	var moveTween = get_tree().create_tween()
	moveTween.tween_property(sprites[sprite],"self_modulate",Color(0.0,0.0,0.0,0.0),tween_length)
	await moveTween.finished
	sprites[sprite].visible = false
	pass

func sprite_reenter(sprite):
	if !sprites.keys().has(sprite) :
		return
	var moveTween = get_tree().create_tween()
	moveTween.tween_property(sprites[sprite],"self_modulate",Color(1.0,1.0,1.0,1.0),tween_length)
	sprites[sprite].visible = true

func flip_sprite(sprite,length : float = 0.0):
	var fTween = get_tree().create_tween()
	fTween.tween_property(sprites[sprite],"scale",Vector2(-sprites[sprite].scale.x,sprite_scale.y),length)
	#sprites[sprite].flip_h = !sprites[sprite].flip_h
	pass
