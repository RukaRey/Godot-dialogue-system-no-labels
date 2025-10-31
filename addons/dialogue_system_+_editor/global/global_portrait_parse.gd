extends Node

var max_portraits := Vector2(5, 5)
var character_portraits := {
	"merry": ["res://misc_assets/MerryPortraits.png", 15],
	"john": ["res://misc_assets/john_face.png", 3]
}

func get_portrait(character_name: String) -> Array:
	if character_name in character_portraits.keys():
		return character_portraits[character_name]
	return []
