extends Node

# Singleton script always be loaded in.
# It will be globally accessible for the entire session,
# and stored variables will not be reset even if the root scene is changed.
# Main purpose is to store and modify stats that need to be persistent such as levels completed, etc

var levelsCompleted: Array[bool] = [false, false, false]	# Tracks what levels the player has completed.
var currentLevel = null										# Tracks the current level the player is in
var isPaused: bool = false									# Tracks whether the game is in a paused state