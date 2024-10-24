extends Node
# The purpose of this node is to designate camera settings for different levels:
# 1. Instantiate component inside mirror
# 2. Set the mirror's @export cameraComponent variable to this
# 3. Set the component's @export settings
# If done correctly, the settings should be copied over to the controlled character every time they switch

@export var limitLeft: float = -1000000
@export var limitRight: float = 1000000
@export var limitBottom: float = 1000000
@export var limitTop: float = -1000000
@export var newOffset: Vector2 = Vector2(0, 0)