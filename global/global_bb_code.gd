extends Node

@onready 
var functions: Dictionary = {
	"[None]": none,
	"[c.red]": color_red,
	"[w.weak]": wave_weak,
	"[jump]": jump,
	"[tremble]": none,
}

var none = func(_itself: Sprite2D): pass

var color_red = func(itself: Sprite2D):
	itself.modulate = Color.RED

var jump = func(itself: Sprite2D):
	var tween = itself.create_tween().set_loops()
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(itself, "position:y", itself.position.y + 5, 0.3)
	tween.tween_property(itself, "position:y", itself.position.y - 5, 0.3)
	

## Ajustar depois
var wave_weak = func(itself: Sprite2D):
	var tween = itself.create_tween().set_loops()
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(itself, "position:y", itself.position.y + 5, 0.3)
	tween.tween_property(itself, "position:y", itself.position.y - 5, 0.3)
	
