extends CanvasLayer

var _game_config = null

onready var _main := $Control
onready var _label := $Control/CC/VC/Label


func _ready():
	pass


func show(text, game_config):
	_game_config = game_config

	if text == null:
		text = "T_GAME_ENDED"
	_label.text = text

	get_tree().paused = true


func _close():
	get_tree().paused = false
	queue_free()


func _on_ButtonRestart_pressed():
	_close()
	GameManager.load_game(_game_config)


func _on_ButtonMenu_pressed():
	_close()
	Utils.change_scene(GameManager.MENU_PATH)
