extends Node

# type of GAME_DATA_CACHE: Dictionary[String, Dictionary]
#                                   (file name) (the data)
const GAME_DATA_CACHE := {}  # NEVER MODIFY THIS, IF YOU DON'T KNOW WHAT YOU ARE DOING!
const GAMES := {}  # type: Dictionary[String, ConfigFile]
const GAME_DISPLAYS := {}  # type: Dictionary[String, gamedisplay]

var _preview_scene := preload("res://menu/gamedisplay.tscn")
var _last_loaded_game: String = ""
var _started_playing_game: int = 0

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu


func _ready():
	_find_games()
	_build_menu()


func load_game(game_cfg: ConfigFile):
	_last_loaded_game = game_cfg.get_meta("folder_name")
	_started_playing_game = OS.get_ticks_msec()
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


func _save_data(file_name: String, data, game: String) -> int:
	"""Save data to a file with for the given game.
	This is a private function, don't use this in a game
	"""
	var cache_key = get_current_player() + "/" + game + "/" + file_name
	var directory = "user://" + get_current_player() + "/" + game + "/"
	Directory.new().make_dir_recursive(directory)
	if not cache_key in GAME_DATA_CACHE:
		GAME_DATA_CACHE[cache_key] = _load_data(file_name, game)
	GAME_DATA_CACHE[cache_key] = data
	var file = File.new()
	file.open(directory + file_name + ".json", File.WRITE)
	file.store_string(JSON.print(GAME_DATA_CACHE[cache_key]))
	file.close()
	return OK


func _load_data(file_name: String, game: String) -> Dictionary:
	"""Load data from a file or GAME_DATA_CACHE and return the data for the game.
	If something doesn't exist an empty Dictionary is returned, which is put in
	the correct location in the GAME_DATA_CACHE Dictionary.
	This is a private function, don't use this in a game.
	"""
	var cache_key = get_current_player() + "/" + game + "/" + file_name
	var directory = "user://" + get_current_player() + "/" + game + "/"
	Directory.new().make_dir_recursive(directory)
	if cache_key in GAME_DATA_CACHE:
		return GAME_DATA_CACHE[cache_key]

	GAME_DATA_CACHE[cache_key] = {}  # populate with default
	# read saved data from a file
	var file = File.new()
	file.open(directory + file_name + ".json", File.READ)

	if not file.is_open():
		return GAME_DATA_CACHE[cache_key]

	var content = file.get_as_text()
	file.close()

	var parse_result = JSON.parse(content)
	if not parse_result.error:
		# put contents from file in the cache
		GAME_DATA_CACHE[cache_key] = parse_result.result

	return GAME_DATA_CACHE[cache_key]


func save_game_data():
	"""Save the changes to the dict returned by get_game_data()
	This method is automatically called when a game ends.
	"""
	assert(_last_loaded_game != "")  # this should only be called if _last_loaded_game is set
	_save_data("game_data", _load_data("game_data", _last_loaded_game), _last_loaded_game)


func get_game_data() -> Dictionary:
	"""Get the game data for the current player and the current game.
	To save data. Just modify the returned Dictionary and call save_game_data().
	"""
	assert(_last_loaded_game != "")
	return _load_data("game_data", _last_loaded_game)


func get_current_player() -> String:
	return "p"  # in future add here more logic


func get_last_played(game_id = null):
	"""Get the time the current player played the currently running game last."""
	game_id = _last_loaded_game if game_id == null else game_id
	assert(game_id != "")
	var data = _load_data("game_meta_data", game_id)
	if not "last_played" in data:
		return null
	var dt = OS.get_datetime_from_unix_time(data["last_played"])
	return (
		"%04d-%02d-%02d %02d:%02d:%02d UTC"
		% [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"], dt["second"]]
	)


func get_played_time(game_id = null) -> float:
	"""Get time the current player played the currently running game."""
	game_id = _last_loaded_game if game_id == null else game_id
	assert(game_id != "")
	var data = _load_data("game_meta_data", game_id)
	if not "played_time" in data:
		return 0.0
	return data["played_time"] / 1000.0


func get_high_score(game_id = null):
	"""Get the high_score of the current player for the currently running game."""
	game_id = _last_loaded_game if game_id == null else game_id
	if not game_id:  # game_id should be the folder_name, not null or ""
		return null
	var data = _load_data("game_meta_data", game_id)

	if not "scores" in data:
		return null

	var scores = data["scores"]
	var high_score = null
	for score in scores:
		if high_score == null or score[0] > high_score:
			high_score = score[0]
	return high_score


# return to the level select
func end_game(message := "", score = null, _status = null):
	var player_name = get_current_player()

	get_tree().change_scene("res://menu/emptySzene.tscn")
	_main.show()

	save_game_data()  # save the data stored while the game was playing

	assert(_last_loaded_game != "")  # should always be set here

	var key

	var data = _load_data("game_meta_data", _last_loaded_game)

	data["last_played"] = OS.get_unix_time()

	if not "played_time" in data:
		data["played_time"] = 0
	data["played_time"] += OS.get_ticks_msec() - _started_playing_game

	if score != null:
		if not "scores" in data:
			data["scores"] = []
		data["scores"].append([score, data["last_played"]])

	_save_data("game_meta_data", data, _last_loaded_game)

	GAME_DISPLAYS[_last_loaded_game].update_text()

	_last_loaded_game = ""
	_started_playing_game = 0

	# this behavior is subject to change
	if message:
		OS.alert(message)


# build the menu from configs in _games
func _build_menu():
	for c in _grid.get_children():
		c.queue_free()
	_main.show()

	#making the buttons
	for game_id in GAMES.keys():
		var display = _preview_scene.instance()
		display.setup(GAMES[game_id])
		display.connect("pressed", self, "load_game")
		_grid.add_child(display)
		GAME_DISPLAYS[game_id] = display


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
