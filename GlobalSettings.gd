extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var audio_button_pressed = false


# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):    
    if Input.is_action_just_released("reset"):
        get_tree().reload_current_scene()
