extends Node2D
# The base level will be responsible for pausing the player and unpausing the player for dialogue

@export var initDialoguePause: bool = true		# Dictates whether the character should be paused for initial dialogue
@export var bossEnemy: CharacterBody2D = null	# If there is a boss, they will be unpaused upon the end of dialogue
var initialControlledCharacter: CharacterBody2D
var musicLoop: AudioStreamPlayer = null
var fogActive = true;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialControlledCharacter = $Entities/ControlledCharacter.get_child(0) # Gets the initial character.

	if initialControlledCharacter != null and initDialoguePause:
		initialControlledCharacter.currentState = 5 # Set the state to pause

	# Initialize vertical mirror normal. Prevents edge cases when transitioning level of the worldboundary normal not being reset when stage changed
	var verticalMirror = $Entities.find_child("VerticalMirror")
	if verticalMirror != null:
		verticalMirror.find_child("CollisionShape2D").shape.normal = Vector2(-1, 0)
	
	# Get the music loop if it exists
	musicLoop = $Music.find_child("MusicLoop")

	if (get_node_or_null("Background/BackgroundThunderController")):
		$Background/BackgroundThunderController.hide()
		$Background/BackgroundThunderController/BrightenCanvasLayer.hide()
		$FogShaderLayer.hide()
		$Entities/Projectiles.hide();
		$Entities/Seija/Sounds/DanmakuSFX.volume_db = -80;

# When dialogue has ended, unpause the character
func _on_dialogue_end_dialogue() -> void:
	initialControlledCharacter.currentState = 0
	if musicLoop != null:
		musicLoop.play()
	if bossEnemy != null:
		bossEnemy.currentState = 0	# Set to idle state after dialogue finishes

func _process(_delta):
	# for the fog shader to correctly not follow the camera
	if get_node_or_null("FogShaderLayer/ColorRect"):
		var viewport = $FogShaderLayer/ColorRect.get_viewport()
		var textureSize = ($FogShaderLayer/ColorRect.material.get_shader_parameter("noise_texture") as Texture2D).get_size()
		var center := viewport.get_camera_2d().get_screen_center_position()
		var viewportSize := viewport.get_visible_rect().size
		$FogShaderLayer/ColorRect.size = viewportSize
		$FogShaderLayer/ColorRect.size = viewportSize
		$FogShaderLayer/ColorRect.material.set_shader_parameter("scale", viewportSize / textureSize)
		$FogShaderLayer/ColorRect.material.set_shader_parameter("displacement", center / textureSize)

func _on_dialogue_dialogue_line_fired(currentLineIndex: int, lineArraySize: int):
	if (currentLineIndex == lineArraySize - 3):
		if (get_node_or_null("Background/BackgroundThunderController")):
			$FogShaderLayer.show()

	if (currentLineIndex == lineArraySize - 1):
		if (get_node_or_null("Background/BackgroundThunderController")):
			$Background/BackgroundThunderController.show()
			$Background/BackgroundThunderController/BrightenCanvasLayer.show()
			$Entities/Projectiles.show();
			$Entities/Seija/Sounds/DanmakuSFX.volume_db = -5;


