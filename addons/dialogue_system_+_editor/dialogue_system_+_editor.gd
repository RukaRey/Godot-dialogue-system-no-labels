@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton(
		"BBCode", 
		"res://addons/dialogue_system_+_editor/global/global_bb_code.gd")
	add_autoload_singleton(
		"PortraitParse", 
		"res://addons/dialogue_system_+_editor/global/global_portrait_parse.gd")


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
