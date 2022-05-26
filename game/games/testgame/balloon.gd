extends TextureButton

var move_offset: float = 0
var ticked: float = 0
var speed: float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ticked += speed * delta
	rect_position.y += sin(move_offset + ticked)
