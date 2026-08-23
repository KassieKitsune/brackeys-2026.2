extends Node

@export_dir var character_folder : String 
@export var portrait_subfolder: String = "Portraits"
@export var default_expression : String = "default"
@export var portrait_extensions : Array[String] = [".png",".svg",".jpg"]
var character_dir

func request_portrait(character:String,expression:String,animated : bool = false) : 
	var portraitFolder = character_folder+"/"+character+"/"+portrait_subfolder
	var portraitDirectory = DirAccess.open(portraitFolder)
	var portFrames : Array[Texture2D] = []
	
	if portraitDirectory != null :
		
		portraitDirectory.list_dir_begin()
		
		var portrait = portraitDirectory.get_next()
		while portrait != "":
			if portrait.contains(expression) && portrait.ends_with(".import"):
				portrait = portrait.trim_suffix(".import")
				for extension in portrait_extensions:
					if portrait.ends_with(extension) :
						var fullPath = portraitFolder+"/"+portrait
						if !animated:
							portraitDirectory.list_dir_end()
							return ResourceLoader.load(fullPath)
						else: 
							portFrames.append(ResourceLoader.load(fullPath))
							break
			portrait = portraitDirectory.get_next()
	return portFrames

func request_character_details(character:):
	var details = read_from_json(character_folder+"/"+character+".")
	return

func read_from_json(path : String):
	var rawFile = FileAccess.open(path,FileAccess.READ)
	var rawText = rawFile.get_as_text()
	var parsedText = JSON.parse_string(rawText)
	if parsedText != null:
		return parsedText
	return null
