extends DialogueDisplay
class_name DialogueEditor

@export var save_path: String = "res://resources/"
@onready var save_wdn: FileDialog = $SaveWdn

@onready var dial_idx_label: Label = $"WholeInterface/TextInterface/HBoxContainer/Dial Idx Label"
@onready var pprt_idx_label: Label = $WholeInterface/PortraitBtn/VBoxContainer/HBoxContainer/PprtIdx

@onready var char_name: TextEdit = $WholeInterface/PortraitBtn/VBoxContainer/HBoxContainer2/CharName
@onready var text_edit: TextEdit = $WholeInterface/TextInterface/HBoxContainer2/TextEdit
@onready var new_button: Button = $WholeInterface/TextInterface/HBoxContainer/NewButton
@onready var save_to_file: Button = $WholeInterface/TextInterface/HBoxContainer/SaveToFile

## Progress buttons for dialogue text
@onready var prev_button: Button = $WholeInterface/TextInterface/HBoxContainer/PrevButton
@onready var next_button: Button = $WholeInterface/TextInterface/HBoxContainer/NextButton

var max_dial_idx := 0
var dial_idx := 0:
	set(idx):
		dial_idx = clamp(idx, 0, max_dial_idx)
		
		dial_idx_label.text = "#" + str(dial_idx)
		prev_button.disabled = dial_idx == 0
		next_button.disabled = dial_idx == max_dial_idx
		
		show_text(dial_idx)
		display_portrait(dial_idx)
	

var dialogue_file: DialogueResource
var dialogue_clone: Array[String] = [""]

var max_pprt_idx := 0
var pprt_idx := 0:
	set(idx):
		pprt_idx = wrap(idx, 0, max_pprt_idx)
		pprt_idx_label.text = str(pprt_idx)
	

var portraits_array: Array = [""]

func activate_editor(active: bool):
	char_name.editable = active
	text_edit.editable = active
	
	new_button.disabled = not active
	save_to_file.disabled = not active

func _new_dialogue_file() -> void:
	dialogue_file = DialogueResource.new()
	
	activate_editor(true)
	

func save_current_dialogue() -> void:
	var num_of_dialogue := dialogue_clone.size() - 1
	
	if dial_idx <= num_of_dialogue: 
		dialogue_clone.remove_at(dial_idx)
	dialogue_clone.insert(dial_idx, text_edit.text)
	#printt("New dialogue", dialogue_clone[dial_idx], "in pos", dial_idx)
	#printt("All dialogue", dialogue_clone)
	

func edit_portrait_idx():
	var pprt_tag: Array = portraits_array[dial_idx].split("_")
	if pprt_tag.size() - 1 == 0: return
	
	pprt_tag[2] = str(pprt_idx) + "]"
	portraits_array[dial_idx] = "_".join(pprt_tag)
	
	display_portrait(dial_idx)
	

func _on_new_dialogue_string() -> void:
	max_dial_idx += 1
	
	dialogue_clone.append("")
	portraits_array.append("")
	
	dial_idx = max_dial_idx
	

func show_text(cur_idx: int):
	if cur_idx <= max_dial_idx:
		text_edit.text = dialogue_clone[cur_idx]
	else:
		text_edit.text = ""

func _on_decrease_dial_idx() -> void:
	dial_idx -= 1
	

func _on_increase_dial_idx() -> void:
	dial_idx += 1
	

func display_portrait(idx: int):
	if idx <= max_dial_idx:
		var portrait: Array = portraits_array[idx].split("_")
		
		if portrait.size() - 1 > 0:
			var c_name: String = portrait[1]
			var c_idx: String = portrait[2].replace("]", "")
			
			max_pprt_idx = PortraitParse.character_portraits[c_name][-1]
			char_name.text = c_name
			pprt_idx = int(c_idx)
			call_portrait(c_name, int(c_idx))
		else:
			max_pprt_idx = 0
			pprt_idx = pprt_idx
			char_pict.texture = null
			char_name.text = ""
		
		#print(portraits_array)
	

func _on_character_name_analysis() -> void:
	var char_possible: = char_name.text.to_lower()
	
	if char_possible in PortraitParse.character_portraits:
		var new_pprt_tag := "[Portrait_"+char_possible+"_"+"0]"
		
		if dial_idx <= portraits_array.size()-1: 
			portraits_array.remove_at(dial_idx)
		portraits_array.insert(dial_idx, new_pprt_tag)
		
		max_pprt_idx = PortraitParse.character_portraits[char_possible][-1]
		
		call_portrait(char_possible, 0)
		#printt("New portrait:", portraits_array)
	

func save_dialogue_to_file(path: String):
	var path_split:= path.split("/")
	
	dialogue_file.dialogue_idx = path_split[-1].replace(".tres", "").to_lower()
	
	for i in range(dialogue_clone.size()):
		dialogue_clone[i] = portraits_array[i] + dialogue_clone[i]
	
	dialogue_file.full_dialogue_sequence = dialogue_clone
	
	ResourceSaver.save(dialogue_file, path)

func _on_current_text_was_edited() -> void:
	save_current_dialogue()


func _on_decrease_pprt_idx() -> void:
	pprt_idx -= 1
	edit_portrait_idx()


func _on_increase_pprt_idx() -> void:
	pprt_idx += 1
	edit_portrait_idx()


func _on_dialogue_file_saved() -> void:
	save_wdn.popup()
	


func _on_save_wdn_file_selected(path: String) -> void:
	save_dialogue_to_file(path)
