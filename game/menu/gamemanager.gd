extends Node

const GAME_DATA_CACHE = {}
const GAMES: Dictionary = {}  # type: Dictionary[str, ConfigFile]

var _preview_scene := preload("res://menu/gamedisplay.tscn")
var _last_loaded_game: String = ""

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu


func _ready():
	load_game_data()  # populate GAME_DATA_CACHE
	_find_games()
	_build_menu()


func load_game(game_cfg: ConfigFile):
	_last_loaded_game = game_cfg.get_meta("_game_name")
	# load the games main scene
	var scene = load(game_cfg.get_meta("_folder_path") + game_cfg.get_value("game", "main_scene"))
	var err := get_tree().change_scene_to(scene)
	if err != OK:
		prints("Error", err)
		return
	_main.hide()


func save_game_data(game, data, write_to_file = true):
	GAME_DATA_CACHE[game] = data
	if write_to_file:
		var file = File.new()
		file.open("user://save_game.dat", File.WRITE)
		file.store_string(JSON.print(GAME_DATA_CACHE))
		file.close()


func load_game_data(game = null):
	if game == null:
		var file = File.new()
		file.open("user://save_game.dat", File.READ)
		if not file.is_open():
			return null
		var content = file.get_as_text()
		file.close()
		if not content:
			return null
		var parse_result = JSON.parse(content)
		if parse_result.error:
			return null
		var data = parse_result.result
		for game in data.keys():
			GAME_DATA_CACHE[game] = data[game]
		return data

	if game in GAME_DATA_CACHE:
		return GAME_DATA_CACHE[game]

	return null


func get_high_score(game, player: String = "player"):
	var data = load_game_data(game)
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
	var player_name = "player"  # this is here to allow for future addition of player names

	get_tree().change_scene("res://menu/emptySzene.tscn")
	_main.show()

	if _last_loaded_game and score != null:
		var data = load_game_data(_last_loaded_game)
		if not data:
			data = {}
		if not "scores" in data:
			data["scores"] = []
		data["scores"].append([score, player_name])
		data["scores"].sort()
		save_game_data(_last_loaded_game, data)
		GAMES[_last_loaded_game].set_meta("_high_score", get_high_score(_last_loaded_game))

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
		display.setup(GAMES[game_name])
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
				var game_path = "res://games/" + file_name + "/game.cfg"

				var err := _load_game_cfg_file(game_path, file_name)
				if err != OK:
					prints("Error loading game cfg:", err)

			file_name = dir.get_next()


# load a config file into _games
func _load_game_cfg_file(path: String, game_name: String) -> int:
	var f := ConfigFile.new()
	var err := f.load(path)
	if err != OK:
		return err
	f.set_meta("_folder_path", path.get_base_dir() + "/")
	f.set_meta("_game_name", game_name)
	f.set_meta("_high_score", get_high_score(game_name))
	GAMES[game_name] = f
	return OK
