extends Node2D
class_name DialogueDisplay

signal sentence_over(is_sentence_over: bool)

signal word_drawn

var font_image := preload("res://fonts/8bitOperator.png")
var letter_object := preload("res://letter_object.tscn")

@export var text_anchor: Marker2D
@onready var char_box: Control = $TextBox/HBoxContainer/CharBox


var char_size := Vector2i(16, 32)
var typewriter_speed: float = 0.025
var char_horizontal_offset: int = int(char_size.x)
var max_indices := font_image.get_size() / Vector2(char_size)

var everychar: String = "
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789
.,“”\'\'\"\'
?!@_*#$%&()+-/:;<=>[\\]^❤{|}~¡¢
"


@onready var char_map := everychar.strip_escapes().split("") 

func _ready() -> void:
	var text_test := "“The rabbit [jump]jumped over[_jump] the river” - 
That's the [c.red]most you can remember[_c.red] of the [w.weak]parallelepipedal[_w.weak] story."
	
	draw_sentence_by_word(text_test)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed( "ui_accept"):
		typewriter_speed = 0.0
		draw_sentence_by_word("Although you can almost certantly remember it was [c.red]yellow.[_c.red]")

func get_char_idx(char_str: String) -> Vector2i:
	var char_idx := char_map.find(char_str)
	
	var y_idx = floor(char_idx/100.0)
	var x_idx = char_idx % 100
	
	return Vector2i(x_idx, y_idx)
	

func split_paragraph(char_num: int, max_chars: Vector2i) -> int:
	var y_idx := -1
	var max_c := max_chars.x  - 1
	
	while(char_num % max_c != 0):
		y_idx += 1
		char_num /= max_chars.x
	
	return y_idx
	

func spawn_letter(char_idx: Vector2, char_bbcode: String, letter_pos := Vector2.ZERO):
	var spr_letter: LetterObject = letter_object.instantiate()
	
	spr_letter.bb_code = char_bbcode
	
	spr_letter.texture = font_image
	spr_letter.hframes = int(max_indices.x)
	spr_letter.vframes = int(max_indices.y)
	spr_letter.frame_coords = char_idx
	spr_letter.global_position = letter_pos
	
	char_box.add_child(spr_letter)
	

func draw_sentence_by_char(
		char_bbcode: String,
		sentence := "Hi this is texx string!",
		starting_offset := Vector2i.ZERO,
	):
	var text_split := sentence.split("")
	
	var x_offset := starting_offset.x
	var y_offset := starting_offset.y
	
	#Adicionando um espaço no começo pra não quebrar a exibição do texto
	text_split.reverse()
	text_split.push_back(" ")
	text_split.reverse()
	text_split = PackedStringArray(text_split)
	
	var max_chars: Vector2i =  Vector2i(char_box.size) / char_size
	
	var char_count := 0
	for character in text_split:
		var char_idx := get_char_idx(character)
		var char_pos: Vector2i = Vector2i(text_anchor.position) + char_size * Vector2i(x_offset, y_offset)
		
		if(
			split_paragraph(char_count, max_chars) != 0
		):
			y_offset += 1
		
		spawn_letter(char_idx, char_bbcode, char_pos)
		x_offset += 1
		
		await get_tree().create_timer(typewriter_speed).timeout
		char_count += 1
	
	word_drawn.emit(char_count)
	
	#return Vector2i(x_offset, y_offset)
	

func draw_sentence_by_word(sentence := "Hi this is sentence!"):
	await get_tree().process_frame
	
	for ch in char_box.get_children():
		if ch is LetterObject: ch.queue_free()
	
	var bb_codes_coords: Dictionary = get_bbcode_coords(sentence)
	
	var clear_sentence := filter_sentence_bbcodes(sentence)
	var text_split := clear_sentence.split(" ")
	
	var word_sizes := []
	var word_char_idx := Vector2i.ZERO
	
	var max_chars: Vector2i =  Vector2i(char_box.size) / char_size
	
	#print(bb_codes_coords)
	
	var final_word: PackedStringArray
	var final_world_location: int
	for word in text_split:
		## Palavras gigantes quebram o sistema, conserte depois
		var split_word := word.split("")
		
		var new_word: Array
		while split_word.size() > max_chars.x:
			for i in max_chars.x - 2:
				new_word.append(split_word[i])
			
			new_word.append("-")
			
			var word_location := text_split.find(word)
			text_split.remove_at(word_location)
			
			text_split.insert(word_location, "".join(new_word))
			new_word.clear()
			
			for i in max_chars.x - 2:
				split_word.remove_at(0)
			
			final_word = split_word
			final_world_location = word_location + 1
		
	
	if text_split[0] == "-": text_split.remove_at(0)
	if final_word: text_split.insert(final_world_location, "".join(final_word))
	
	for word in text_split:
		word_sizes.append((word.split("").size() + 1) * char_size.x)
	
	var sum_sizes := 0
	var char_count := 0
	
	var current_bbcode: String = "[None]"
	var current_bb_cords := Vector2(-1, 0)
	for i in text_split.size():
		sum_sizes += word_sizes[i]
		
		#printt("Soma dos tamanhos: ", sum_sizes)
		#printt("Tamanho.x da caixa: ", char_box.size.x - 32)
		
		#printt("Current char:", char_count)
		
		for bbcode in bb_codes_coords.keys():
			var bb_coords: Array = bb_codes_coords[bbcode]
			for bb in bb_coords:
				if char_count >= bb.x and char_count < bb.y :
					#printt("Inside bb section:", bbcode, bb)
					current_bbcode = bbcode
					current_bb_cords = bb
					var bb_found = bb_coords.find(bb)
					bb_coords.remove_at(bb_found)
				
		
		if char_count > current_bb_cords.y:
			current_bbcode = "[None]"
		
		if sum_sizes > char_box.size.x - 16:
			#print("Passou do limite!\n")
			sum_sizes = word_sizes[i]
			word_char_idx.x = 0
			word_char_idx.y += 1
		
		draw_sentence_by_char(current_bbcode, text_split[i], word_char_idx)
		
		printt("this signal happened")
		var current_char = await word_drawn
		
		word_char_idx.x += current_char
		char_count += current_char
		
	
	sentence_over.emit(true)

func search_for_bbcodes(bbcode: String, sentence: String) -> Array:
	var bb_code_at := 0
	var bb_codes_pos: Array
	
	while bb_code_at != -1:
		bb_code_at = sentence.find(bbcode)
		if bb_code_at == -1: break
		
		var cur_color_at := sentence.find(bbcode)
		sentence = sentence.erase(cur_color_at, bbcode.length())
		
		var bb_breaker := bbcode.erase(0)
		bb_breaker = "[_" + bb_breaker
		
		var bb_breaker_at := sentence.find(bb_breaker)
		if bb_breaker_at == -1: break
		sentence = sentence.erase(bb_breaker_at, bb_breaker.length())
		
		bb_codes_pos.append(Vector2i(bb_code_at, bb_breaker_at))
	
	return bb_codes_pos
	

func get_bbcode_coords(
		sentence: String = "[wave]Me text[_wave] [color]test[_color]aaa"
	) -> Dictionary:
	var rough_bbcodes := {}
	
	for key in BBCode.functions:
		var sentence_w_o_other_bbs: String = sentence
		
		for bb in BBCode.functions:
			if bb == key: continue
			var break_bb = "[_" + bb.erase(0)
			
			sentence_w_o_other_bbs = sentence_w_o_other_bbs.replace(bb, "")
			sentence_w_o_other_bbs = sentence_w_o_other_bbs.replace(break_bb, "")
		
		rough_bbcodes[key] = search_for_bbcodes(key, sentence_w_o_other_bbs)
	
	return rough_bbcodes
	

func filter_sentence_bbcodes(sentence: String) -> String:
	var clear_sentence := sentence
	
	for bb in BBCode.functions:
		clear_sentence = clear_sentence.replace(bb, "")
		clear_sentence = clear_sentence.replace("[_" + bb.erase(0), "")
	
	return clear_sentence
	
