extends PanelContainer
signal start_game(player_inputs)

var _current_input_player_selctor_index = 0
var _player_inputs = []

onready var _players = $MarginContainer/VBoxContainer/MarginContainer/Players
onready var _back_button: Button = $MarginContainer/VBoxContainer/Buttons/HBoxContainer/BackButton
onready var _play_button: Button = $MarginContainer/VBoxContainer/Buttons/HBoxContainer2/PlayButton


func _ready():
	for i in range(_players.get_child_count()):
		var player_select = _players.get_children()[i]
		if i != 0:
			player_select.set_process_input(false)
		player_select.connect("got_input", self, "_on_player_select_got_input")


func _on_player_select_got_input(input_type: Array):
	# Don't accept input, if that input type is already used by annother player
	if _player_inputs.has(input_type):
		return
	_player_inputs.push_back(input_type)
	# Stop getting inputs from current selector
	var current_selector = _players.get_child(_current_input_player_selctor_index)
	current_selector.get_input = false
	# Don't display next input_selector, if its the last one
	if _current_input_player_selctor_index + 1 >= _players.get_child_count():
		return
	_current_input_player_selctor_index += 1
	# Display and get input to select the input method for the next player
	var next_selector = _players.get_child(_current_input_player_selctor_index)
	next_selector.display = true
	next_selector.get_input = true
	# Show back button and enable play button, if at least one player selected thier input scheme
	if _current_input_player_selctor_index > 0:
		_play_button.disabled = false
		_back_button.show()


func _on_back_button_up():
	# Reset/hide current selector
	var current_selector = _players.get_child(_current_input_player_selctor_index)
	_player_inputs.pop_back()
	if current_selector.get_input == false:
		current_selector.get_input = true
		return
	current_selector.get_input = false
	current_selector.display = false
	# Get input from last selector
	_current_input_player_selctor_index -= 1
	var old_selector = _players.get_child(_current_input_player_selctor_index)
	old_selector.get_input = true
	# Hide back button, if at start
	if _current_input_player_selctor_index == 0:
		_back_button.hide()


func _on_play_button_up():
	emit_signal("start_game", _player_inputs)


func _on_help_button_up():
	$HelpPopup.popup_centered_ratio(0.85)
