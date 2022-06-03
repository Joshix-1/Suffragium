extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed

onready var _main := $Margin
onready var _restart_btn := $Margin/VBox/restartbtn
onready var _quit_game_btn := $Margin/VBox/quitgamebtn


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
	var is_in_game = null != GameManager.last_loaded_game
	_restart_btn.visible = is_in_game
	_quit_game_btn.visible = is_in_game


func _on_restartbtn_pressed():
	hide()
	var game: Node = get_tree().root.get_children()[-1]
	if game.has_method("restart"):
		game.restart()
	else:
		get_tree().reload_current_scene()


func _on_quitgamebtn_pressed():
	GameManager.end_game("")
	hide()


func _on_quittodesctopbtn_pressed():
	GameManager.end_game("")
	get_tree().quit()
