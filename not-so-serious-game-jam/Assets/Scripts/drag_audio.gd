extends AudioStreamPlayer2D

const mute_db := -80.0

@export var fadeOutTime = 10

var isPlaying :bool = false
var isDraging :bool = false

var lastPos :float = 0.0

var tweenVol
var tweenPitch
var tweenPan 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()
	
	
func _process(_delta: float) -> void:
	print(volume_db)
			

func start() ->void:
	var trackLength = stream.get_length()
	volume_db = mute_db
	
	
#add fix if multiple fades for the same
func fadeTo(targetValue: float, targetParam: String, fadeTime: float, tween:Tween ) ->Tween:
	if (tween != null):
		tween.kill
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property($".", targetParam, targetValue, fadeTime)
	return tween

func dragUpdate(mouseX: float, delta: float) -> void:
	isDraging = true
	var velocity: float
	if !isPlaying:
		play()
		isPlaying = true
	#maths
	position = Vector2 (mouseX,0)
	if (lastPos != 0.0):
		velocity = ((mouseX - lastPos)/delta)
	else:
		velocity = 0
		pass
	#need to test values 
	#print(velocity)
	
	#To do: add maths based of velocity to set pitch from 1 - 4 and volume -80db to 0db
	lastPos = mouseX
	
	
func dragStop() -> void:
		isDraging = false
		fadeTo(0,"volume_db",fadeOutTime,tweenVol)
		
