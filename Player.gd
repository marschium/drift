extends Spatial

# Node references
onready var ball = $Ball
onready var car_mesh = $CarMesh
onready var body_mesh = $CarMesh/tmpParent/sedanSports/body
onready var left_wheel = $CarMesh/tmpParent/sedanSports/wheel_frontLeft
onready var right_wheel = $CarMesh/tmpParent/sedanSports/wheel_frontRight
onready var camera = $Camera
onready var smoke_left = $CarMesh/SmokeLeft
onready var smoke_right = $CarMesh/SmokeRight
onready var brake_left = $CarMesh/Lights/LeftBrakelight
onready var brake_right = $CarMesh/Lights/RightBrakelight
onready var scenery_collision = $CarMesh/SceneryRigidBody
onready var engine_audio = $EngineAudio
onready var skid_audio = $SkidAudio
onready var impact_audio = $ImpactAudio
onready var skids = [
    $CarMesh/tmpParent/sedanSports/wheel_backLeft/SkidMark,
    $CarMesh/tmpParent/sedanSports/wheel_backRight/SkidMark,
    $CarMesh/tmpParent/sedanSports/wheel_frontLeft/SkidMark,
    $CarMesh/tmpParent/sedanSports/wheel_frontRight/SkidMark,
]
onready var global_settings = get_node("/root/GlobalSettings")

var camera_offset = Vector3(0, 0, 0)
var sphere_offset = Vector3(0, -1.0, 0)
var acceleration = 50
var steering = 21.0
var turn_speed = 5
var turn_stop_limit = 1.5
var body_pitch = 160
var body_tilt = 35
var accelerate_timer = 0.0

var speed_input = 0
var rotate_input = 0

func _ready():
    camera_offset = camera.transform.origin    
    var global_settings = get_node("/root/GlobalSettings")
    _on_AudioButton_toggled(global_settings.audio_button_pressed)

func _physics_process(_delta):
    car_mesh.transform.origin = ball.transform.origin + sphere_offset
    camera.transform.origin = car_mesh.transform.origin + camera_offset
    ball.add_central_force(-car_mesh.global_transform.basis.z * speed_input)

func _process(delta):
    speed_input = 0
    speed_input += Input.get_action_strength("accelerate")
    speed_input -= Input.get_action_strength("brake")
    
    rotate_input = 0
    rotate_input += Input.get_action_strength("steer_left")
    rotate_input -= Input.get_action_strength("steer_right")
    rotate_input *= deg2rad(steering)
    left_wheel.rotation.y = rotate_input * deg2rad(40)
    right_wheel.rotation.y = rotate_input * deg2rad(40)
    
    if speed_input > 0.0:
        speed_input *= acceleration
        accelerate_timer += delta
        brake_left.visible = false
        brake_right.visible = false
        engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, 100.0 / speed_input, delta)
    if speed_input < 0.0:
        speed_input *= acceleration / 2.0         
        rotate_input = rotate_input * -1
        brake_left.visible = true
        brake_right.visible = true        
        engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, 1.0, delta)
    else:          
        accelerate_timer = 0.0 
        engine_audio.pitch_scale = lerp(engine_audio.pitch_scale, 1.0, delta)
    
    
    if ball.linear_velocity.length() > turn_stop_limit:
        var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, rotate_input)
        car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
        
        var t = -rotate_input * (ball.linear_velocity.length() / body_tilt)
        body_mesh.rotation.z = lerp(body_mesh.rotation.z, t, 10 * delta)
        
        var t2 = min(accelerate_timer, 1.0) * (ball.linear_velocity.length() / body_pitch)        
        body_mesh.rotation.x = lerp(body_mesh.rotation.x, t2, 10 * delta)
        
        car_mesh.global_transform = car_mesh.global_transform.orthonormalized() 

        if (speed_input > 0) and ((accelerate_timer > 0.0 and accelerate_timer < 0.5) or (abs(rotate_input) > 0.1 and abs(speed_input) > 0.5)):
            smoke_left.emitting = true
            smoke_right.emitting = true
            skid_audio.volume_db = -15
        else:            
            smoke_left.emitting = false
            smoke_right.emitting = false
            skid_audio.volume_db = -80


func _on_AudioButton_toggled(button_pressed):
    skid_audio.playing = !button_pressed
    engine_audio.playing = !button_pressed    
    global_settings.audio_button_pressed = button_pressed


func _on_SceneryRigidBody_body_entered(body):
    if !global_settings.audio_button_pressed:
        impact_audio.play()
