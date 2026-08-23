extends Node

@onready var MusicTrack = $BackingTrack

@export_dir var sfx_folder : String = "res://Audio/SFX"
@export_dir var music_folder : String = "res://Audio/Music"
@export var accepted_extensions : Array[String] = [".ogg",".wav",".mp3"]
var tweener : Tween
# Called when the node enters the scene tree for the first time.

var soundList = []

func _ready():
	MusicTrack.play()
	pass # Replace with function body.

func change_music(song : AudioStream):
	tweener = get_tree().create_tween()
	if MusicTrack.stream != song:
		if MusicTrack.playing :
			var newtrack = MusicTrack.duplicate()
			newtrack.stream = song
			newtrack.volume_db = -80
			add_child(newtrack)
			newtrack.play()
			tweener.set_parallel()
			tweener.tween_property(MusicTrack,"volume_db",-80,1)
			tweener.tween_property(newtrack,"volume_db",0,1)
			await tweener.finished 
			MusicTrack.queue_free()
			MusicTrack = newtrack
		else:
			tweener.tween_property(MusicTrack,"volume_db",0,1)
			MusicTrack.stream = song
			MusicTrack.play()
		pass
	tweener.kill()

func play_sound(sound : AudioStream,volume : float = 0, pitch : float = 1.0, bus : String = "SFX", position : Vector2 = Vector2.ZERO):
	if !soundList.has(sound) :
		soundList.append(sound)
	var player
	if position == Vector2.ZERO:
		player = AudioStreamPlayer.new()
	else :
		player = AudioStreamPlayer2D.new()
		player.global_position = position
	player.bus = bus
	player.stream = sound
	player.volume_db = volume
	player.pitch_scale = pitch
	add_child(player)
	player.play()
	await player.finished
	if soundList.has(sound):
		soundList.erase(sound)
	player.queue_free()
	#add_child()

func check_soundList(sound:AudioStream):
	return soundList.has(sound)

func request_sound(sound:String) : 
	var sfxDirectory = DirAccess.open(sfx_folder)
	var options : Array[String] = []
	
	if sfxDirectory != null :
		
		sfxDirectory.list_dir_begin()
		
		var sfx = sfxDirectory.get_next()
		while sfx != "":
			if sfx.contains(sound) && sfx.ends_with(".import"):
				sfx = sfx.trim_suffix(".import")
				for extension in accepted_extensions:
					if sfx.ends_with(extension) :
						var fullPath = sfx_folder+"/"+sfx
						options.append(fullPath)
						break
			sfx = sfxDirectory.get_next()
	if options.size() > 0 :
		return ResourceLoader.load(options.pick_random())
	else : return null

func request_music(title:String) : 
	var musicDirectory = DirAccess.open(music_folder)
	print("A")
	if musicDirectory != null :
		
		musicDirectory.list_dir_begin()
		
		var music = musicDirectory.get_next()
		while music != "":
			if music.contains(title) && music.ends_with(".import"):
				music = music.trim_suffix(".import")
				for extension in accepted_extensions:
					if music.ends_with(extension) :
						var fullPath = music_folder+"/"+music
						print(fullPath)
						return ResourceLoader.load(fullPath)
			music = musicDirectory.get_next()
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		change_music(load("res://TestMaterials/mus.ogg"))
#	if Input.is_action_just_pressed("ui_cancel"):
#		change_music(load("res://TestMaterials/mus_tutorial.ogg"))
#	pass
