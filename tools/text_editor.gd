extends DialogueDisplay
class_name DialogueEditor

@export var save_path: String = "res://resources/"
@onready var save_wdn: FileDialog = $SaveWdn
@onready var open_file: FileDialog = $OpenFile

@onready var dial_idx_label: Label = $"WholeInterface/PortraitBtn/Spacer/FileOptions/Dial Idx Label"
@onready var pprt_idx_label: Label = $WholeInterface/PortraitBtn/PanelContainer/VBoxContainer/HBoxContainer/PprtIdx
@onready var tags_options: OptionButton = $WholeInterface/TextInterface/HBoxContainer/TagsOptions
@onready var text_for_filename: Label = $PanelContainer/HBoxContainer/TextForFilename

@onready var char_name: TextEdit = $WholeInterface/PortraitBtn/PanelContainer/VBoxContainer/HBoxContainer2/CharName
@onready var text_edit: TextEdit = $WholeInterface/TextInterface/HBoxContainer2/TextEdit
@onready var new_button: Button = $WholeInterface/TextInterface/HBoxContainer/NewButton
@onready var save_to_file: Button = $PanelContainer/HBoxContainer/SaveToFile
@onready var apply_tag: Button = $WholeInterface/TextInterface/HBoxContainer/ApplyTag
@onready var timer_interval: LineEdit = $WholeInterface/TextInterface/HBoxContainer/TimerInterval
@onready var add_timer: Button = $WholeInterface/TextInterface/HBoxContainer/AddTimer
@onready var view_dialogue: Button = $PanelContainer/HBoxContainer/ViewDialogue

## Progress buttons for dialogue text
@onready var prev_button: Button = $WholeInterface/TextInterface/HBoxContainer/PrevButton
@onready var next_button: Button = $WholeInterface/TextInterface/HBoxContainer/NextButton
@onready var prev_prt_button: Button = $WholeInterface/PortraitBtn/PanelContainer/VBoxContainer/HBoxContainer/PrevPrtButton
@onready var next_prt_button: Button = $WholeInterface/PortraitBtn/PanelContainer/VBoxContainer/HBoxContainer/NextPrtButton

var max_dial_idx := 0
var dial_idx := 0:
	set(idx):
		dial_idx = clamp(idx, 0, max_dial_idx)
		
		dial_idx_label.text = "Dialogue #" + str(dial_idx)
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

func _ready() -> void:
	var s_highlighter: CodeHighlighter = text_edit.syntax_highlighter
	s_highlighter.add_color_region("[", "]", Color.CORAL)
	s_highlighter.add_color_region("{", "}", Color.STEEL_BLUE)
	
	for bb_code in BBCode.functions.keys():
		tags_options.add_item(bb_code)

func _input(event: InputEvent) -> void:
	if event.is_action_released("mouse_left"):
		if text_edit.has_selection() and tags_options.selected != 0: 
			apply_tag.disabled = false

func activate_editor(active: bool):
	char_name.editable = active
	text_edit.editable = active
	timer_interval.editable = active
	
	#apply_tag.disabled = not active
	view_dialogue.disabled = not active
	add_timer.disabled = not active
	tags_options.disabled = not active
	new_button.disabled = not active
	save_to_file.disabled = not active

func _new_dialogue_file() -> void:
	dialogue_file = DialogueResource.new()
	
	text_for_filename.text = "Creating new dialogue...."
	dialogue_file.dialogue_idx = "current_dialogue"
	
	char_name.clear()
	char_pict.texture = null
	dial_idx_label.text = "Dialogue #0"
	timer_interval.text = "1.0"
	pprt_idx_label.text = "0"
	
	dialogue_clone.clear()
	portraits_array.clear()
	
	dialogue_clone.append("")
	portraits_array.append("")
	
	apply_tag.disabled = true
	next_button.disabled = true
	prev_button.disabled = true
	
	text_edit.clear()
	max_dial_idx = 0
	tags_options.select(0)
	
	activate_editor(true)
	

func _on_open_file_pressed() -> void:
	open_file.popup()
	

func _on_file_selected(path: String) -> void:
	dialogue_file = load(path)
	var filename: PackedStringArray = path.split("/")
	
	text_for_filename.text = "Editing " + filename[-1] + "'s dialogue...."
	
	dialogue_clone.clear()
	portraits_array.clear()
	
	for sentence in dialogue_file.full_dialogue_sequence:
		var pprt_tag := find_portrait_tag(sentence.split(" "))
		if pprt_tag:
			dialogue_clone.append(sentence.replace(pprt_tag["string"], ""))
			portraits_array.append(pprt_tag["string"])
		else:
			dialogue_clone.append(sentence)
			portraits_array.append("")
	
	max_dial_idx = dialogue_file.full_dialogue_sequence.size() - 1
	dial_idx = 0
	
	show_text(dial_idx)
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
			var c_name: String = portrait[1].to_lower()
			var c_idx: String = portrait[2].replace("]", "")
			
			max_pprt_idx = PortraitParse.character_portraits[c_name][-1]
			char_name.text = c_name
			pprt_idx = int(c_idx)
			call_portrait(c_name, int(c_idx))
			
			prev_prt_button.disabled = false
			next_prt_button.disabled = false
		else:
			max_pprt_idx = 0
			pprt_idx = pprt_idx
			char_pict.texture = null
			char_name.text = ""
			
			prev_prt_button.disabled = true
			next_prt_button.disabled = true
		
		#print(portraits_array)
	

func _on_character_name_analysis() -> void:
	var char_possible: = char_name.text.to_lower()
	
	if char_possible in PortraitParse.character_portraits:
		var new_pprt_tag := "[Portrait_"+char_possible+"_"+"0]"
		
		if dial_idx <= portraits_array.size()-1: 
			portraits_array.remove_at(dial_idx)
		portraits_array.insert(dial_idx, new_pprt_tag)
		
		#printt("Portrait updated:", portraits_array)
		
		prev_prt_button.disabled = false
		next_prt_button.disabled = false
		
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
	

func add_tags_to_word(text: String ,option_idx: int) -> String:
	var bb_codes := BBCode.functions.keys()
	var tag: String = bb_codes[option_idx]
	var close: String = "[_" + tag.erase(0)
	
	return tag + text + close
	

func add_timer_tags_to_sentence(timer: float):
	return "{aw_" + str(timer) + "}"
	

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
	

func _on_apply_tag_pressed() -> void:
	var selected_text = text_edit.get_selected_text()
	
	if not selected_text: return
	apply_tag.disabled = true
	text_edit.delete_selection()
	
	var tagged_text: String = add_tags_to_word(
		selected_text, tags_options.selected)
	
	text_edit.insert_text_at_caret(tagged_text)
	

func _on_tags_options_item_selected(index: int) -> void:
	apply_tag.disabled = index == 0 or not text_edit.has_selection()
	

func _on_timer_interval_entered(new_text: String) -> void:
	if not new_text.is_valid_float() and not new_text == "": #previnir negativo depois
		timer_interval.text = str(0.0)
	

func _on_add_timer_pressed() -> void:
	var timer_text: String = add_timer_tags_to_sentence(float(timer_interval.text))
	
	text_edit.insert_text_at_caret(timer_text)
	

func _on_view_dialogue_pressed() -> void:
	var box_window := Window.new()
	box_window.title = "Running: " + dialogue_file.dialogue_idx
	box_window.size = get_viewport_rect().size * 0.8
	box_window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	box_window.unresizable = false
	box_window.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	
	box_window.max_size = get_viewport_rect().size
	
	box_window.close_requested.connect(
		func ():
			box_window.queue_free()
	)
	
	var ehxibition_text := DialogueResource.new()
	var array_exibition := dialogue_clone.duplicate()
	var portrait_exibit := portraits_array.duplicate()
	
	for i in range(array_exibition.size()):
		array_exibition[i] = portrait_exibit[i] + array_exibition[i]
	ehxibition_text.full_dialogue_sequence = array_exibition
	
	var dialogue_scene: DialogueBox = preload("res://dialogue_box.tscn").instantiate()
	dialogue_scene.dialogue_sequence = ehxibition_text
	
	box_window.add_child(dialogue_scene)
	get_tree().root.add_child(box_window)
	
