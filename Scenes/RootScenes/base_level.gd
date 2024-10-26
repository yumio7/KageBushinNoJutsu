extends Node2D
# The base level will be responsible for pausing the player and unpausing the player for dialogue

@export var initDialoguePause: bool = true	# Dictates whether the character should be paused for initial dialogue
var initialControlledCharacter: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialControlledCharacter = $Entities/ControlledCharacter.get_child(0) # Gets the initial character.

	if initialControlledCharacter != null and initDialoguePause:
		initialControlledCharacter.currentState = 5 # Set the state to pause

# When dialogue has ended, unpause the character
func _on_dialogue_end_dialogue() -> void:
	initialControlledCharacter.currentState = 0
