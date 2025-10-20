extends Sprite2D
class_name LetterObject

var bb_code: String
var bb_function: Callable

var my_lambda_dict = {
	"add": func(a, b): return a + b,
	"subtract": func(a, b): return a - b,
	"multiply": func(a, b): return a * b
}

func _ready() -> void:
	bb_function = BBCode.functions[bb_code]
	
	bb_function.call(self)
