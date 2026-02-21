extends Node

class_name DialogueLoader

var dialogues = {}
var characters = {}

func load_all(charactersPath:= "", dialoguesPath:=""):
	if charactersPath != "":
		load_characters(charactersPath)
	if dialoguesPath != "":
		load_dialogues(dialoguesPath)

func load_characters(path):
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	characters = data["characters"]

func load_dialogues(path):
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	
	for dialogue in data["Dialogues"]:
		var nodes = {}
		for n in dialogue["Texts"]:
			var node = DialogueNode.new()
			node.id = n["ID"]
			node.type = n["Type"]
			node.character = n["Character"]
			node.text_key = n["Text"]
			node.next = int(n["Next"] if n.has("Next") and n["Next"] != null else -1)
			
			if n.has("Options"):
				for o in n["Options"]:
					var opt = DialogueOption.new()
					opt.text_key = o["Text"]
					opt.next = o["Next"]
					node.options.append(opt)
			
			nodes[node.id] = node
		
		dialogues[int(dialogue["DialogueID"])] = nodes
