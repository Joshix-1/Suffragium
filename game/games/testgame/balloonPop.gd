# warning-ignore-all:return_value_discarded
extends MarginContainer

const END_MESSAGE := "You got %s points!"
const STATUS_MESSAGE := "You'r in stage %s/10 and have %s points!"

var balloon_scene := preload("res://games/testgame/balloon.tscn")

var colors := {
	"Red": Color.red,
	"Green": Color.green,
	"Yellow": Color.yellow,
	"Blue": Color.blue,
	"Purple": Color.purple,
	"Orange": Color.orange,
}

var points := 0
var search_color: Color
var stage := 0

onready var _respawn_timer := $respawnTimer
onready var _color_label := $VBoxContainer/HBoxContainer/ColorLabel
onready var _status_label := $VBoxContainer/HBoxContainer/StatusLabel
onready var _area := $VBoxContainer/balloonArea
onready var _rng := RandomNumberGenerator.new()
onready var _particles := $VBoxContainer/Particles2D


func _ready():
	_rng.randomize()
	start()


func start():
	var i = _rng.randi_range(0, colors.size() - 1)
	_color_label.text = "Pop the %s balloon" % colors.keys()[i]
	search_color = colors.values()[i]
	call_deferred("_spawn")


# spawns all balloons per round
func _spawn():
	var possible := colors.values()
	possible.erase(search_color)

	#spawn 5-10 balloons of any color exept the search color
	for _i in range(_rng.randi_range(5, 10)):
		_spawn_color(possible[_rng.randi_range(0, possible.size() - 1)])
		
	#spawn 1 balloon with the search color
	_spawn_color(search_color)

	stage += 1
	_update_status()

# spawns one balloon of the given color
func _spawn_color(color: Color):
	var b: TextureButton = balloon_scene.instance()
	_area.add_child(b)
	# position
	var max_pos: Vector2 = _area.rect_size - b.rect_size * b.rect_scale
	b.rect_position.x = _rng.randf_range(0, max_pos.x)
	b.rect_position.y = _rng.randf_range(0, max_pos.y)
	
	b.set("move_offset", _rng.randf_range(0, 2 * PI))
	b.set("speed", _rng.randf_range(0.9, 4))

	# signals
	b.connect("pressed", self, "_on_destroy", [color, b])
	b.connect("pressed", b, "queue_free")
	# modulate
	b.self_modulate = color


func _on_destroy(color: Color, button = null):
	if color.is_equal_approx(search_color):
		points += 1
		_delete_all()
		if button is TextureButton:
			_particles.global_position = (
				button.rect_global_position
				+ button.rect_size / 2 * button.rect_scale
			)
			_particles.restart()
		_respawn_timer.start()
	else:
		points -= 1
	_update_status()


func _delete_all():
	for b in _area.get_children():
		b.queue_free()


# timer leaves a little time between stage end and the next stage start or game end
func _on_respawn_timer_timeout():
	if stage >= 10:
		GameManager.end_game(END_MESSAGE % points)
		return
	_spawn()


func _update_status():
	_status_label.text = STATUS_MESSAGE % [stage, points]
