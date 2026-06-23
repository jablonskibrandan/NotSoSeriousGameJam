extends AudioStreamPlayer2D

const mute_db := -80.0

@export var fadeOutTime : float

var isPlaying :bool = false
var isDraging :bool = false

var lastPos :float = 0.0
var lastV :float = 0.0
var filteredVelocity: float

var tweenVol
var tweenPitch
var tweenPan 

@export var minV: float
@export var maxV: float

@export var minVol: float
@export var maxVol: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var trackLength = stream.get_length() #used before to get random start location but not used atm
	volume_db = mute_db
	
	
#func _process(_delta: float) -> void:
	#print(volume_db)
	
	
#add fix if multiple fades for the same
func fadeTo(targetValue: float, targetParam: String, fadeTime: float, tween:Tween ) ->Tween:
	if (tween != null):
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, targetParam, targetValue, fadeTime)
	return tween

func dragUpdate(mouseX: float, delta: float) -> void:
	isDraging = true
	var velocity: float
	var normalisedV: float
	if !isPlaying:
		play()
		isPlaying = true
	#maths
	position = Vector2 (mouseX,0)
	if (lastPos != 0.0):
		velocity = ((mouseX - lastPos)/delta)
	else:
		velocity = 0
	#need to test values
	velocity = abs(velocity)
	#velocity = clampf(velocity,0.0,maxV)
	filteredVelocity = lerpf(filteredVelocity,abs((mouseX - lastPos) / delta),0.1)
	normalisedV = clampf(inverse_lerp(minV, maxV, filteredVelocity),0.0,1.0) 
	if normalisedV > lastV:
		if tweenPitch:
			tweenPitch.kill()
		pitch_scale = lerpf(pitch_scale,3.0 * normalisedV, 0.30)
		if tweenVol:
			tweenVol.kill()
		volume_db = lerpf(minVol,maxVol,normalisedV) 
	else:
		tweenPitch = fadeTo(3*normalisedV, "pitch_scale", fadeOutTime, tweenPitch)
		tweenVol = fadeTo( lerpf(mute_db,maxVol,normalisedV) ,"volume_db", fadeOutTime, tweenVol)
	lastV = normalisedV
	lastPos = mouseX

	#To do: add maths based of velocity to set pitch from 1 - 4 and volume -80db to 0db
	
	
	
func dragStop() -> void:
	if isDraging:
		isDraging = false
		lastPos = 0.0
		tweenPitch = fadeTo(1, "pitch_scale", fadeOutTime, tweenPitch)
		tweenVol = fadeTo(mute_db,"volume_db",fadeOutTime,tweenVol)
		lastV = 0.0
