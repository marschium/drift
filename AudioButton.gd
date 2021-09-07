extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():    
    var global_settings = get_node("/root/GlobalSettings")
    pressed = global_settings.audio_button_pressed
