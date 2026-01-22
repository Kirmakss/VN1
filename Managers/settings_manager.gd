extends Node

# Скорость текста в символах/сек
var text_cps: float = 30.0

const MIN_TEXT_CPS := 5.0
const MAX_TEXT_CPS := 120.0

func set_text_cps(value: float) -> void:
	text_cps = clamp(value, MIN_TEXT_CPS, MAX_TEXT_CPS)
	print("Text speed set to:", text_cps)
