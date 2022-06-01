extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed

onready var _main := $Margin


func _ready():
	hide()


func _input(event):
	if !event is InputEventKey:
		return
	if !event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return

	if _main.visible:
		hide()
	else:
		show()
	get_tree().set_input_as_handled()


func show():
	_main.show()
	emit_signal("pause_menu_opened")
	get_tree().paused = true
	_update_menu()


func _update_menu():
	var game: ConfigFile = GameManager.last_loaded_game
	# change the menu base on the game.cfg settings.
#	if game.get_value()


func hide():
	_main.hide()
	emit_signal("pause_menu_closed")
	get_tree().paused = false


func _on_restartbtn_pressed():
	var game: Node = get_tree().root.get_children()[-1]
	if game.has_method("reset"):
		game.reset()


func _on_quitgamebtn_pressed():
	GameManager.end_game("")
	hide()


func _on_quittodesctopbtn_pressed():
	GameManager.end_game("")
	get_tree().quit()
