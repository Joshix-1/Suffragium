extends Node

const GAME_DATA_CACHE := {}  # type: Dictionary[String, Dictionary[String, ...]]
const GAMES := {}  # type: Dictionary[String, ConfigFile]

var _preview_scene := preload("res://menu/gamedisplay.tscn")
var _last_loaded_game: String = ""

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu


func _ready():
	_find_games()
	_build_menu()


func load_game(game_cfg: ConfigFile):
	_last_loaded_game = game_cfg.get_meta("folder_name")
	# load the games main scene
	var scene = load(
		(
			"res://games/"
			+ game_cfg.get_meta("folder_name")
			+ "/"
			+ game_cfg.get_value("game", "main_scene")
		)
	)
	var err := get_tree().change_scene_to(scene)
	if err != OK:
		prints("Error", err)
		return
	_main.hide()


func save_game_data(file_name: String, game: String, data):
	if not file_name in GAME_DATA_CACHE:
		load_game_data(file_name, game)
	GAME_DATA_CACHE[file_name][game] = data
	var file = File.new()
	file.open("user://" + file_name + ".json", File.WRITE)
	file.store_string(JSON.print(GAME_DATA_CACHE[file_name]))
	file.close()


func load_game_data(file_name: String, game: String):
	if not file_name in GAME_DATA_CACHE:
		GAME_DATA_CACHE[file_name] = {}  # populate with default
		var file = File.new()
		file.open("user://" + file_name + ".json", File.READ)
		if file.is_open():
			var content = file.get_as_text()
			file.close()
			var parse_result = JSON.parse(content)
			if not parse_result.error:
				var data = parse_result.result
				for game in data.keys():
					GAME_DATA_CACHE[file_name][game] = data[game]

	if game in GAME_DATA_CACHE[file_name]:
		return GAME_DATA_CACHE[file_name][game]

	return null


func get_high_score(game, player: String = "p"):
	var data = load_game_data("game_scores", game)
	if data == null:
		return null
	if not "scores" in data:
		return null
	var scores = data["scores"]
	var high_score = null
	for score in scores:
		if score[1] == player and (high_score == null or score[0] > high_score):
			high_score = score[0]
	return high_score


# return to the level select
func end_game(message := "", score = null, _status = null):
	var player_name = "p"  # this is here to allow for future addition of player names

	get_tree().change_scene("res://menu/emptySzene.tscn")
	_main.show()

	if _last_loaded_game and score != null:
		var data = load_game_data("game_scores", _last_loaded_game)
		if not data:
			data = {}
		if not "scores" in data:
			data["scores"] = []
		data["scores"].append([score, player_name])
		save_game_data("game_scores", _last_loaded_game, data)

	# this behavior is subject to change
	if message:
		OS.alert(message)

	_last_loaded_game = ""


# build the menu from configs in _games
func _build_menu():
	for c in _grid.get_children():
		c.queue_free()
	_main.show()

	#making the buttons
	for game_name in GAMES.keys():
		var display = _preview_scene.instance()
		display.setup(GAMES[game_name], self)
		display.connect("pressed", self, "load_game")
		_grid.add_child(display)


# go through every folder inside res://games/ and try to load the game.cfg into _games
func _find_games():
	GAMES.clear()
	var dir = Directory.new()
	if dir.open("res://games") == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var err := _load_game_cfg_file(file_name)
				if err != OK:
					prints("Error loading game cfg:", err)

			file_name = dir.get_next()


# load a config file into _games
func _load_game_cfg_file(folder_name: String) -> int:
	var config := ConfigFile.new()
	var err := config.load("res://games/" + folder_name + "/game.cfg")
	if err != OK:
		return err
	config.set_meta("folder_name", folder_name)
	GAMES[folder_name] = config
	return OK
