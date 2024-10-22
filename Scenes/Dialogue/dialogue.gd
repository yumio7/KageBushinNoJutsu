extends Control

# Signal level to various events
signal endDialogue
signal startDialogue
signal proceedDialogue

# Variables for dialogue behavior
@export var dialogueComponents: Array[CutsceneComponent] = []
var usedComponent: CutsceneComponent = null
var usedCompInd = 0
var nameTable: Array = []
var emoteTable: Array = []
var lineTable: Array = []
@onready var soundToUse = $SoundLib/Default
var dialogueIndex = 0
var activeDialogue = false
var currentLine = ""

# Variables for skipping dialogue
var writing = false
#var skip = false

func _ready():
	dialogueSequence(0)

# Begin dialogue sequence
func dialogueSequence(desiredComponentIndex):
	startDialogue.emit()
	visible = true
	#$Skip.visible = true
	var tweenIn = create_tween()
	var tweenKagIn = create_tween()
	var tweenMitsuIn = create_tween()
	tweenIn.tween_property($DialoguePanel, "position", Vector2(0, 0), .2).set_trans(Tween.TRANS_QUAD)
	tweenKagIn.tween_property($Kag, "position", Vector2(35, 34), .2).set_trans(Tween.TRANS_QUAD)
	tweenMitsuIn.tween_property($Mitsu, "position", Vector2(300, 34), .2).set_trans(Tween.TRANS_QUAD)
	activeDialogue = true
	dialogueIndex = 0
	usedCompInd = desiredComponentIndex
	usedComponent = dialogueComponents[desiredComponentIndex]
	nameTable = usedComponent.nameSequence
	emoteTable = usedComponent.emoteSequence
	lineTable = usedComponent.dialogueSequence
	
	for i in nameTable.size():
		writeDialogue(nameTable[dialogueIndex], emoteTable[dialogueIndex], lineTable[dialogueIndex])
		await proceedDialogue
		#if skip == true: break
	
	#$Skip.visible = false
	#skip = false
	activeDialogue = false
	var tweenOut = create_tween()
	var tweenKagOut = create_tween()
	var tweenMitsuOut = create_tween()
	tweenOut.tween_property($DialoguePanel, "position", Vector2(0, 120), .2).set_trans(Tween.TRANS_QUAD)
	tweenKagOut.tween_property($Kag, "position", Vector2(-170, 52), .2).set_trans(Tween.TRANS_QUAD)
	tweenMitsuOut.tween_property($Mitsu, "position", Vector2(500, 52), .2).set_trans(Tween.TRANS_QUAD)
	tweenOut.tween_callback(invisibleDialogue)
	endDialogue.emit()
	

func invisibleDialogue():
	visible = false

# Write dialogue.
func writeDialogue(Dname, emote, _line):
	$SpeakDelay.start()
	matchSpriteData(Dname, emote)
	currentLine = ""
	$DialoguePanel/Name.text = Dname
	$DialoguePanel/Dialogue.text = ""
	writing = true

func _process(_delta):
	if writing == true and currentLine != lineTable[dialogueIndex]:
		currentLine = lineTable[dialogueIndex].left(currentLine.length() + 1)
		$DialoguePanel/Dialogue.text = currentLine
	elif writing == true and currentLine == lineTable[dialogueIndex]:
		writing = false
		$SpeakDelay.stop()

# Match speaker name to specific sound to use
func matchSpriteData(Dname, emote):
	match Dname:
		"Minamitsu":
			soundToUse = $SoundLib/Minamitsu
			#$Mitsu.set_emotion(emote)
		"Kagerou":
			soundToUse = $SoundLib/Kagerou
			$Kag.set_emotion(emote)
		"Wakasagihime":
			soundToUse = $SoundLib/Wakasagihime
		"Nazrin":
			soundToUse = $SoundLib/Nazrin
		"Seija":
			soundToUse = $SoundLib/Seija
		"Shinmyoumaru":
			soundToUse = $SoundLib/Shinmyoumaru
		_:
			soundToUse = $SoundLib/Default

func _input(event):
	if event.is_action_released("ui_accept") and activeDialogue == true:
		if writing == true:
			writing = false
			$SpeakDelay.stop()
			$DialoguePanel/Name.text = nameTable[dialogueIndex]
			$DialoguePanel/Dialogue.text = lineTable[dialogueIndex]
		elif writing == false:
			dialogueIndex += 1
			proceedDialogue.emit()


func _on_speak_delay_timeout():
	soundToUse.play()


# func _on_skip_pressed():
# 	writing = false
# 	$SpeakDelay.stop()
# 	skip = true
# 	proceedDialogue.emit()
# 	$DialoguePanel/Name.text = "Halfpot"
# 	$DialoguePanel/Dialogue.text = "Adios"
