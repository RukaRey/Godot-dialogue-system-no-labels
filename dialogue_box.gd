extends Node2D
class_name DialogueBox

signal interaction_input
signal skip_dialogue

@export 
var dialogue_sequence: DialogueResource
@onready 
var dialogue_display: DialogueDisplay = $DialogueDisplay

func _ready() -> void:
	skip_dialogue.connect(dialogue_display.skip_text)
	
	run_sequence()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel_input"):
		skip_dialogue.emit()
	
	if event.is_action_pressed("interaction_input"):
		interaction_input.emit()
	

func run_sequence():
	var full_dialogue := dialogue_sequence.full_dialogue_sequence
	
	for dialogue: String in full_dialogue:
		dialogue_display.draw_string_sentence(dialogue)
		await dialogue_display.sentence_over
		await interaction_input
	
	queue_free()
