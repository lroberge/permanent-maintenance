extends MarginContainer

var dialogue
var msg_template

var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		dialogue_line = next_dialogue_line
		var chatline = ""
		if not dialogue_line.character.is_empty():
			chatline += "[code]" + dialogue_line.character + "[/code]" + ": "
		chatline += dialogue_line.text + "\n"
		$ChatText.append_text(chatline)
		if dialogue_line.time != null:
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ChatText.text = ""
	dialogue = load("res://test_dialogue.dialogue") as DialogueResource
	dialogue_line = await dialogue.get_next_dialogue_line("chatting_test")

func next(next_id: String) -> void:
	self.dialogue_line = await dialogue.get_next_dialogue_line(next_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
