extends DialogueDisplay
class_name DialogueEditor

@onready var open_file: FileDialog = $OpenFile
@onready var char_name: TextEdit = $WholeInterface/PortraitBtn/VBoxContainer/HBoxContainer2/CharName
@onready var text_idx_label: Label = $WholeInterface/PortraitBtn/VBoxContainer/HBoxContainer/TextIdx
@onready var change: Button = $WholeInterface/PortraitBtn/VBoxContainer/HBoxContainer2/Change
@onready var save: Button = $WholeInterface/PortraitBtn/VBoxContainer/Save

@export var text_edit: TextEdit 

@export var previous_button: Button
@export var next_button: Button

@export var prev_prt_button: Button 
@export var next_prt_button: Button 


var portrait: Dictionary

var max_portrait_idx := 0
var portrait_idx := 0:
	set(idx):
		portrait_idx = wrap(idx, 0, max_portrait_idx)
		text_idx_label.text = str(portrait_idx)
		
		call_portrait(character_name, portrait_idx)
	

var dialogue_idx := 0:
	set(idx):
		var max_idx := dialogue_array.size() - 1
		dialogue_idx = clamp(idx, 0, max_idx)
		
		previous_button.disabled = idx == 0
		next_button.disabled = idx == max_idx
		

var bb_code_coords: Dictionary

var character_name: String:
	set(c_name):
		character_name = c_name
		char_name.text = c_name
var dialogue_array: Array[String]

var saved_text: String

func _ready() -> void:
	previous_button.connect("pressed", _on_prev_button_pressed)
	next_button.connect("pressed", _on_next_button_pressed)
	
	prev_prt_button.connect("pressed", prev_portrait)
	next_prt_button.connect("pressed", next_portrait)
	



func treat_text(text_idx: int):
	var sentence = change_dialogue(text_idx)
	var text_split: PackedStringArray = sentence.split(" ")
	
	portrait = find_portrait_tag(text_split)
	saved_text = " ".join(text_split)
	
	if portrait:
		change.disabled = false
		update_portrait(portrait, int(portrait["idx"]))
		text_edit.text = saved_text.replace(portrait["string"],"")
	

func update_portrait(new_portrait: Dictionary, pprt_idx: int):
	character_name = new_portrait["name"]
	text_idx_label.text = new_portrait["idx"]
	
	var pprt_info: Array = PortraitParse.character_portraits[
		character_name.to_lower()]
	
	max_portrait_idx = pprt_info[-1]
	
	portrait_idx = pprt_idx
	

func change_dialogue(idx: int) -> String:
	return dialogue_array[idx]
	

func display_portrait():
	if char_name.text.to_lower() not in PortraitParse.character_portraits: 
		return
	
	var text_split := saved_text.split(" ")
	var new_portrait :Dictionary = find_portrait_tag(text_split)
	
	if not new_portrait: return
	
	var searching_str: String = "_" + new_portrait["name"]
	var searching_idx: String = "_" + new_portrait["idx"]
	
	saved_text = saved_text.replace(searching_str, "_" + char_name.text)
	saved_text = saved_text.replace(searching_idx, "_" + text_idx_label.text )
	text_split = saved_text.split(" ")
	
	new_portrait = find_portrait_tag(text_split)
	
	character_name = new_portrait["name"]
	
	var pprt_info: Array = PortraitParse.character_portraits[
		character_name.to_lower()]
	
	max_portrait_idx = pprt_info[-1]
	


func _on_opened(path: String) -> void:
	var dialogue: DialogueResource = load(path)
	
	char_name.editable = true
	
	character_name = dialogue.dialogue_idx
	dialogue_array = dialogue.full_dialogue_sequence
	
	dialogue_idx = dialogue_idx
	treat_text(dialogue_idx)
	


func prev_portrait() -> void:
	portrait_idx -= 1

func next_portrait() -> void:
	portrait_idx += 1

func _on_open_pressed() -> void:
	open_file.size = get_viewport().size * 0.8
	
	open_file.popup()

func _on_prev_button_pressed() -> void:
	dialogue_idx -= 1
	treat_text(dialogue_idx)

func _on_next_button_pressed() -> void:
	dialogue_idx += 1
	treat_text(dialogue_idx)

func _on_save_pressed() -> void:
	display_portrait()
	
	portrait_idx = int(text_idx_label.text)
	dialogue_array[dialogue_idx] = saved_text

func _on_char_name_text_changed() -> void:
	display_portrait()
	
	portrait_idx = 0

## New dialogue area
func _on_new_dialogue() -> void:
	char_name.editable = true
	character_name = "John"
	
	dialogue_array.append("[Portrait_John_0]Hi!")
	
	portrait_idx = max_portrait_idx
	max_portrait_idx = dialogue_array.size() - 1
	
	
