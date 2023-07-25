extends PanelContainer

var currchoices: Array[DialogueResponse]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Chat.choice_required.connect(choice_requested)
	pass # Replace with function body.


func choice_requested(choices: Array[DialogueResponse], time: float):
	visible = true
	%ChoiceText1.text = choices[0].text
	%ChoiceText2.text = choices[1].text
	currchoices = choices

func _unhandled_key_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("dialogue_choice1"):
			make_choice(currchoices[0])
		elif event.is_action_pressed("dialogue_choice2"):
			make_choice(currchoices[1])



func make_choice(choice: DialogueResponse):
	Chat.make_choice(choice)
	visible = false
	currchoices = []
