@icon("res://addons/dialogue_system_+_editor/misc_assets/dial_box_icon.svg")
extends Node
class_name DialogueBox
## Top node of the dialogue node tree, controls operation.
##
## Sets if dialogue exhibited is interactable, and which dialogue to load in a DialogueDisplay child.

signal interaction_input
signal skip_dialogue

@export
var is_interactive: bool = true
@export 
var dialogue_sequence: DialogueResource
@export 
var dialogue_display: DialogueDisplay 


func _ready() -> void:
	skip_dialogue.connect(dialogue_display.skip_text)
	
	set_process_input(is_interactive)
	run_sequence()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_input"):
		skip_dialogue.emit()
	
	if event.is_action_pressed("interaction_input"):
		interaction_input.emit()
	

func run_sequence():
	if not is_instance_valid(dialogue_sequence): return
	var full_dialogue := dialogue_sequence.full_dialogue_sequence
	
	for dialogue: String in full_dialogue:
		dialogue_display.draw_string_sentence(dialogue)
		await dialogue_display.sentence_over
		await interaction_input
	
	queue_free()
