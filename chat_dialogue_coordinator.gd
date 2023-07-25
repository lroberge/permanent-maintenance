extends Node

signal choice_required(choices: Array[DialogueResponse], time: float)
signal choice_made(choice: DialogueResponse)

func present_choice(choices: Array[DialogueResponse], time: float):
	choice_required.emit(choices, time)

func make_choice(choice: DialogueResponse):
	choice_made.emit(choice)
