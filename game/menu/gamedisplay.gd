extends MarginContainer

signal pressed(game_file)

var game_file: ConfigFile


func setup(game_cfg: ConfigFile):
	game_file = game_cfg

	$VBoxContainer/Label.text = game_cfg.get_value("game", "name")
	_on_VBoxContainer_draw()

	var icon: Texture = load(
		str(
			"res://games/",
			game_cfg.get_meta("folder_name"),
			"/",
			game_cfg.get_value("game", "icon")
		)
	)
	if icon == null:
		icon = load("res://icon.png")
	$VBoxContainer/TextureRect.texture = icon

	#setup of info Dialog
	##setup buttons
	$InfoButton.connect("pressed", $InfoDialog, "popup_centered_minsize", [Vector2(500, 250)])
	var loadbtn = $InfoDialog.add_button("load")
	loadbtn.connect("pressed", $InfoDialog, "hide")
	loadbtn.connect("pressed", self, "_on_loadbutton_pressed")
	##setup text
	$InfoDialog/Container/Label.text = game_cfg.get_value("game", "name")
	$InfoDialog/Container/TextureRect.texture = icon
	$InfoDialog/Container/descCont/desclab.bbcode_text = game_cfg.get_value("game", "desc")
	var text = ""
	text += "Author: " + game_cfg.get_value("game", "creator") + "\n"
	text += "Version: " + game_cfg.get_value("game", "version") + "\n"
	$InfoDialog/Container/descCont/Statslab.text = text


func _on_VBoxContainer_draw():
	var text = game_file.get_value("game", "desc")

	var high_score = GameManager.get_high_score(game_file.get_meta("folder_name"))
	if high_score != null:
		text += "\n\nHighscore: " + str(high_score)

	# update the high_score displayed in $VBoxContainer/RichTextLabel
	if $VBoxContainer/RichTextLabel.bbcode_text != text:
		$VBoxContainer/RichTextLabel.bbcode_text = text


func _on_loadbutton_pressed():
	emit_signal("pressed", game_file)
