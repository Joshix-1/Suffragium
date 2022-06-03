extends CanvasLayer

onready var _main := $Margin
onready var _menu_text := $Margin/VBox/Label


func _ready():
	hide()


func _input(event):
	if not event is InputEventKey:
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return

	if is_open():
		_on_restartbtn_pressed()
		get_tree().set_input_as_handled()


func show(text: String):
	_menu_text.text = text
	_main.show()
	get_tree().paused = true


func hide():
	_main.hide()
	get_tree().paused = false


func is_open():
	return _main.visible


func _on_restartbtn_pressed():
	hide()
	var game: Node = get_tree().root.get_children()[-1]
	if game.has_method("restart"):
		game.restart()
	else:
		get_tree().reload_current_scene()


func _on_quitgamebtn_pressed():
	hide()
	GameManager.open_gamemenu()
