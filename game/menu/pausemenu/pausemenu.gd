extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed

onready var _main := $Margin
onready var _reset_btn := $Margin/VBox/restartbtn


func _ready():
	hide()


func _input(event):
	if !event is InputEventKey:
		return
	if !event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return

	if is_open():
		hide()
	else:
		show()
	get_tree().set_input_as_handled()


func show():
	_main.show()
	emit_signal("pause_menu_opened")
	get_tree().paused = true
	_update_menu()


func hide():
	_main.hide()
	emit_signal("pause_menu_closed")
	get_tree().paused = false


func is_open():
	return _main.visible


func _update_menu():
	var game: ConfigFile = GameManager.last_loaded_game
	if !is_instance_valid(game):
		# when no game is loaded use an empty config.
		game = ConfigFile.new()
	# change the menu base on the game.cfg settings.
	var resetable: bool = game.get_value("features", "allow_restart", false)
	_reset_btn.visible = resetable


func _on_restartbtn_pressed():
	var game: Node = get_tree().root.get_children()[-1]
	if game.has_method("restart"):
		game.reset()
		hide()


func _on_quitgamebtn_pressed():
	GameManager.end_game("")
	hide()


func _on_quittodesctopbtn_pressed():
	GameManager.end_game("")
	get_tree().quit()
