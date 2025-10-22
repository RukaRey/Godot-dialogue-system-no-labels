extends Node

var max_portraits := Vector2(5, 5)
var character_portraits := {
	"merry": "res://misc_assets/MerryPortraits.png",
}

func get_portrait(character_name: String) -> String:
	if character_name in character_portraits.keys():
		return character_portraits[character_name]
	return ""
