extends DialogueParser

var lexer : RegEx
func _ready() -> void:
	lexer = RegEx.new()
	lexer.compile("[#!]\\w+|\\^[\\d.]+|\\?\\?|@\\(.+\\)|<.+<|>>\\n|-\\s*|: *.+|>.*?>|(><)|~\\d*?~|[\\w\\d]+[-+];|{[^]]+?}+|=.+?=")
	super()

func lex(file_path:String):
	var rawFile = FileAccess.open(file_path,FileAccess.READ)
	var textFile = rawFile.get_as_text()
	var lResult = lexer.search_all(textFile)
	var strings : Array[String] = []
	for result in lResult:
		strings.append(result.strings[0])
	return strings

func read_from_file(path : String = load_from_file) :
	if path.ends_with(".json"):
		return super()
	var lexResults : PackedStringArray = lex(path)
	var parseArray : Array[Dictionary] = []
	var current_dict : Dictionary
	var writing_to
	for lR in lexResults:
		#####################################/LINE INFORMATION/####################################

		if lR.begins_with("-"): #Start New Line
			print(current_dict)
			current_dict = {}
			writing_to = current_dict
			parseArray.append(current_dict)
		elif lR == "~~": #Autoscrolling
			writing_to["autoscroll"] = true
		elif lR.begins_with("~") && lR.ends_with("~"):
			var stripped = lR.lstrip("~").rstrip("~").strip_edges()
			if str(int(stripped)) == stripped:
				writing_to["go_to"] = int(stripped)
		elif lR.begins_with("=") && lR.ends_with("="): #Set_new Scene
			var stripped = lR.lstrip("=").rstrip("=").strip_edges()
			writing_to["next_scene"] = stripped
		elif lR == "><": # Close scene
			writing_to["close"] = true

		####################################/SPEAKER INFO/###################################

		elif lR.begins_with("#"): # Speaker Name
			writing_to["character"] = lR.lstrip("#").strip_edges()
		elif lR.begins_with("!"): # Expression
			writing_to["expression"] = lR.lstrip("!").strip_edges()

		##################################/SPRITE ANIMATION/##################################

		elif lR.begins_with("@"): # Sprite Position, checks if the sections are valid floats
			var stripped = lR.lstrip("@(").rstrip(")").strip_edges()
			var split = stripped.split(",")
			if str(float(split[0])) == split[0]:
				writing_to["h_position"] = float(split[0])
			if str(float(split[1])) == split[1]:
				writing_to["v_position"] = float(split[1])
		elif lR.begins_with(":"): # Dialogue Text
			var stripped =  lR.lstrip(":").strip_edges()
			writing_to["text"] = stripped.replace("|","")
			if stripped.contains("|"):
				writing_to["syllables"] = stripped
		elif lR == "??": # Sprite Flip
			writing_to["flip"] = true
		elif lR.begins_with("^"): # Animation Tween Time
			var stripped = lR.lstrip("^").strip_edges()
			if str(float(stripped)) == stripped:
				writing_to["tween_length"] = float(stripped)

		################################/BRANCHES + CHOICES/##################################

		elif lR.begins_with(">") && lR.ends_with(">"):
			var stripped = lR.lstrip(">").rstrip(">").strip_edges()
			if stripped.begins_with("*"): # Merge Branches which are *ed
				if writing_to.get("merge_branches") is not Array:
					writing_to["merge_branches"] = []
				if stripped != "*":
					writing_to["merge_branches"].append(stripped.lstrip("*"))

			else: # Begin Branch
				writing_to["begin_branch"] = stripped
		elif lR.begins_with("<") && lR.ends_with("<"): # Choices
			var stripped = lR.lstrip("<").rstrip("<".strip_edges())
			if writing_to.get("choices") is not Array:
				writing_to["choices"] = []
			writing_to["choices"].append(stripped)

		####################################/CONDITIONS/######################################

		elif lR.ends_with(";"): # Positive Conditions
			var stripped = lR.rstrip(";")
			if stripped.ends_with("+"):
				stripped = stripped.rstrip("+")
				if current_dict.get("positive_conditions") is not Array:
					current_dict["positive_conditions"] = {}
				if current_dict["positive_conditions"].get(stripped) is not Dictionary:
					current_dict["positive_conditions"][stripped] = {}
					writing_to = current_dict["positive_conditions"][stripped]
			elif stripped.ends_with("-"): # Negative Conditions
				stripped = stripped.rstrip("-")
				if current_dict.get("negative_conditions") is not Array:
					current_dict["negative_conditions"] = {}
				if current_dict["negative_conditions"].get(stripped) is not Dictionary:
					current_dict["negative_conditions"][stripped] = {}
					writing_to = current_dict["negative_conditions"][stripped]

		##################################/EMBEDDED JSON/#####################################

		elif lR.begins_with("{") && lR.ends_with("}"):
			var json = JSON.parse_string(lR)
			if json is Dictionary:
				for key in json.keys(): writing_to[key] = json[key]
	print(current_dict)
	return(parseArray)
