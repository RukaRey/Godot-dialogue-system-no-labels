extends Node2D
class_name DialogueDisplay

signal sentence_over(is_sentence_over: bool)

var font_image := preload("res://fonts/8bitOperator.png")
var letter_object := preload("res://letter_object.tscn")


@export_range(0.0, 1.0, 0.025) 
var base_typewriter_speed: float = 0.025
@export 
var text_anchor: Marker2D
@export 
var char_box: Control
@export 
var char_pict: TextureRect

var char_size := Vector2i(16, 32)
var typewriter_speed: float
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


func get_char_idx(char_str: String) -> Vector2i:
	var char_idx := char_map.find(char_str)
	
	var y_idx = floor(char_idx/100.0)
	var x_idx = char_idx % 100
	
	return Vector2i(x_idx, y_idx)
	

## Possibly deprecated
func split_paragraph(char_num: int, max_chars: Vector2i) -> int:
	var y_idx := -1
	var max_c := max_chars.x  - 1
	
	while(char_num % max_c != 0):
		y_idx += 1
		char_num /= max_chars.x
	
	return y_idx
	

func spawn_letter(
		char_idx: Vector2,
		char_bbcode: String,
		bb_delay : float,
		letter_pos := Vector2.ZERO,
		):
	var spr_letter: LetterObject = letter_object.instantiate()
	
	spr_letter.bb_code = char_bbcode
	spr_letter.bb_delay = bb_delay
	
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
	
	var _max_chars: Vector2i =  Vector2i(char_box.size) / char_size
	
	var char_count := 0
	var bb_delay_count := -1
	for character in text_split:
		var char_idx := get_char_idx(character)
		var char_pos: Vector2i = Vector2i(text_anchor.position) + char_size * Vector2i(x_offset, y_offset)
		
		#if(
			#split_paragraph(char_count, max_chars) != 0
		#):
			#y_offset += 1
		
		if typewriter_speed == 0:
			bb_delay_count += 1
		
		spawn_letter(char_idx, char_bbcode, bb_delay_count, char_pos)
		x_offset += 1
		
		if typewriter_speed > 0:
			await get_tree().create_timer(typewriter_speed).timeout
		char_count += 1
	
	return char_count

func draw_string_sentence(
	sentence := "Hi, [aw:0.5]this[_aw:0.5] is a test sentence! [aw:0.5][c.red]Try[_c.red][_aw:0.5] adding your own."
	):
	typewriter_speed = base_typewriter_speed
	text_anchor.position.x = 24
	char_pict.texture = null
	
	await get_tree().process_frame
	
	max_indices = font_image.get_size() / Vector2(char_size)
	
	for ch in char_box.get_children():
		if ch is LetterObject: ch.queue_free()
	
	var bb_codes_coords: Dictionary = get_bbcode_coords(sentence)
	
	var clear_sentence := filter_sentence_bbcodes(sentence)
	var text_split := clear_sentence.split(" ")
	var portrait := find_portrait_tag(text_split)
	
	if portrait:
		var tag_size: int = portrait["string"].length()
		
		for bb in bb_codes_coords.keys():
			if bb_codes_coords[bb].size() == 0: continue
			
			for i in range(bb_codes_coords[bb].size()):
				bb_codes_coords[bb][i] -= Vector2i.ONE * tag_size
			
		text_split[0] = text_split[0].replace(portrait["string"],"")
		call_portrait(portrait["name"], int(portrait["idx"]))
	
	
	
	var word_sizes := []
	var word_char_idx := Vector2i.ZERO
	
	var max_chars: Vector2i =  Vector2i(char_box.size) / char_size
	
	#print(bb_codes_coords)
	
	var final_word: PackedStringArray
	var final_word_location: int
	for word in text_split:
		var split_word := word.split("")
		
		var new_word: Array
		while split_word.size() > max_chars.x:
			for i in max_chars.x - 1:
				new_word.append(split_word[i])
			
			new_word.append("-")
			
			var word_location := text_split.find(word)
			
			if word_location != -1:
				text_split.remove_at(word_location)
				text_split.insert(word_location, "".join(new_word))
			else:
				text_split.append("".join(new_word))
			new_word.clear()
			
			for i in max_chars.x - 1:
				split_word.remove_at(0)
			
			final_word = split_word
			
			if word_location != -1:
				final_word_location = word_location + 1
			else:
				final_word_location = text_split.size()
		
	
	if text_split[0] == "-": text_split.remove_at(0)
	if final_word: text_split.insert(final_word_location, "".join(final_word))
	
	for word in text_split:
		word_sizes.append((word.split("").size() + 1) * char_size.x)
	
	var sum_sizes := 0
	var char_count := 0
	
	var current_bbcode: String = "[None]"
	var current_bb_cords := Vector2(-1, 0)
	
	for i in text_split.size():
		
		var timer_adjustments = await apply_timers(
			text_split[i], 
			word_sizes[i],
		)
		
		if timer_adjustments:
			text_split[i] = timer_adjustments[0]
			word_sizes[i] = timer_adjustments[1]
			
			#printt("BB codes:", bb_codes_coords)
			
			for bb_idx in bb_codes_coords.keys():
				for idz in range(bb_codes_coords[bb_idx].size()):
					bb_codes_coords[bb_idx][idz] -= (timer_adjustments[1] / char_size.x + 1) * Vector2i.ONE
		
		sum_sizes += word_sizes[i]
		
		for bbcode in bb_codes_coords.keys():
			var bb_coords: Array = bb_codes_coords[bbcode]
			for bb in bb_coords:
				if char_count >= bb.x and char_count < bb.y :
					current_bbcode = bbcode
					current_bb_cords = bb
					var bb_found = bb_coords.find(bb)
					bb_coords.remove_at(bb_found)
		
		if char_count > current_bb_cords.y:
			current_bbcode = "[None]"
		
		if sum_sizes > char_box.size.x - 32:
			#print("Passou do limite!\n")
			sum_sizes = word_sizes[i]
			word_char_idx.x = 0
			word_char_idx.y += 1
		
		
		var current_char_count = await draw_sentence_by_char(
			current_bbcode, text_split[i], word_char_idx)
		
		word_char_idx.x += current_char_count
		char_count += current_char_count
		
	
	sentence_over.emit(true)
	

func find_portrait_tag(text_split: PackedStringArray) -> Dictionary:
	var regex := RegEx.new()
	regex.compile("\\[Portrait_([A-Za-z]+)_([0-9]+)\\]")
	
	var portrait_info: Dictionary
	
	for results in regex.search_all(text_split[0]):
		portrait_info = {
			"string": results.get_string(),
			"name": results.get_string(1),
			"idx": results.get_string(2),
		}
	
	return portrait_info
	

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
	

func call_portrait(character_name: String, portrait_idx: int):
	if not is_instance_valid(char_pict): return
	
	var portrait: String = PortraitParse.get_portrait(character_name.to_lower())
	var atlas_texture := AtlasTexture.new()
	
	atlas_texture.atlas = load(portrait)
	
	var picture_size := Vector2(
		atlas_texture.atlas.get_width() / 15,
		atlas_texture.atlas.get_height()
	)
	
	var char_pic_idx := portrait_idx * picture_size.x
	
	atlas_texture.region = Rect2(char_pic_idx, 0, picture_size.x, picture_size.y)
	
	char_pict.texture = atlas_texture
	
	text_anchor.position.x -= 32
	char_box.size.x -= picture_size.x
	

func find_await_timers(word: String) -> Dictionary:
	var regex := RegEx.new()
	regex.compile("\\[aw_([0-9]*\\.[0-9]+)\\]")
	
	var timer_info: Dictionary
	
	for results in regex.search_all(word):
		
		timer_info = {
			"string": results.get_string(),
			"timer": results.get_string(1),
		}
			
	
	return timer_info
	

func apply_timers(word: String, 
	word_size: int, 
	):
	
	var timer_info := find_await_timers(word)
	if not timer_info: return
	
	var t_timer := float(timer_info["timer"])
	word_size -= timer_info["string"].length() * char_size.x
	
	await get_tree().create_timer(t_timer).timeout
	
	return [word.replace(timer_info["string"], ""), word_size,]


func skip_text():
	typewriter_speed = 0.0
	
