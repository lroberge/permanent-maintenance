@tool
extends Node3D

var AoEColor: Color = Color.MAGENTA:
	set(color):
		AoEColor = color
		$outline.modulate = AoEColor
		$outline/inner.modulate = AoEColor
		$outline/inner_highlight.modulate = AoEColor
