extends MarginContainer

var dialogue = preload("res://ui/test_dialogue.dialogue")

var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		dialogue_line = next_dialogue_line
		var chatline = ""
		if not dialogue_line.character.is_empty():
			chatline += "[code]" + dialogue_line.character + "[/code]" + ": "
		chatline += dialogue_line.text + "\n"
		$ChatText.append_text(chatline)
		if dialogue_line.responses.size() > 0:
			Chat.present_choice(dialogue_line.responses, dialogue_line.time)
		if dialogue_line.time != null:
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ChatText.get_v_scroll_bar().value_changed.connect(scrolled)
	$ChatText.text = ""
	Chat.choice_made.connect(continue_from_choice)
	scrolled($ChatText.get_v_scroll_bar().value)
	dialogue_line = await dialogue.get_next_dialogue_line("chatting_test")

func next(next_id: String) -> void:
	self.dialogue_line = await dialogue.get_next_dialogue_line(next_id)

func continue_from_choice(response: DialogueResponse):
	self.dialogue_line = await dialogue.get_next_dialogue_line(response.next_id)


func scrolled(value: float) -> void:
	if value > 0:
		$ChatText/ScrollFadeTop.visible = true
	else:
		$ChatText/ScrollFadeTop.visible = false

	if value < ($ChatText.get_v_scroll_bar().max_value - $ChatText.get_v_scroll_bar().page):
		$ChatText/ScrollFadeBot.visible = true
	else:
		$ChatText/ScrollFadeBot.visible = false
	pass
