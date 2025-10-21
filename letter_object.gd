extends Sprite2D
class_name LetterObject

var bb_code: String
var bb_function: Callable

var bb_delay: float = 0

func _ready() -> void:
	bb_function = BBCode.functions[bb_code]
	
	bb_function.call(self, bb_delay)
