extends Control

# Signal level to various events
signal endDialogue
signal proceedDialogue

# Variables for dialogue behavior
@export var dialogueComponents: Array[CutsceneComponent] = []
var usedComponent: CutsceneComponent = null
var usedCompInd = 0
var nameTable: Array = []
var lineTable: Array = []
@onready var soundToUse = $SoundLib/Default
var dialogueIndex = 0
var activeDialogue = false
var currentLine = ""

# Variables for skipping dialogue
var writing = false
var skip = false

# Begin dialogue sequence
func dialogueSequence(desiredComponentIndex):
	visible = true
	$Skip.visible = true
	var tweenIn = create_tween()
	tweenIn.tween_property($DialoguePanel, "position", Vector2(0, 680), .2).set_trans(Tween.TRANS_QUAD)
	activeDialogue = true
	dialogueIndex = 0
	usedCompInd = desiredComponentIndex
	usedComponent = dialogueComponents[desiredComponentIndex]
	nameTable = usedComponent.nameSequence
	lineTable = usedComponent.dialogueSequence
	
	for i in nameTable.size():
		writeDialogue(nameTable[dialogueIndex], lineTable[dialogueIndex])
		await proceedDialogue
		if skip == true: break
	
	$Skip.visible = false
	skip = false
	activeDialogue = false
	var tweenOut = create_tween()
	tweenOut.tween_property($DialoguePanel, "position", Vector2(0, 1080), .2).set_trans(Tween.TRANS_QUAD)
	tweenOut.tween_callback(invisibleDialogue)
	endDialogue.emit(usedCompInd)
	

func invisibleDialogue():
	visible = false

# Write dialogue. If input is taken during the writing process, skip
func writeDialogue(Dname, _line):
	$SpeakDelay.start()
	matchSoundLib(Dname)
	currentLine = ""
	$DialoguePanel/Name.text = Dname
	$DialoguePanel/Dialogue.text = ""
	writing = true

func _process(_delta):
	if writing == true and skip == false and currentLine != lineTable[dialogueIndex]:
		currentLine = lineTable[dialogueIndex].left(currentLine.length() + 1)
		$DialoguePanel/Dialogue.text = currentLine
	elif writing == true and currentLine == lineTable[dialogueIndex]:
		writing = false
		$SpeakDelay.stop()

# Match speaker name to specific sound to use
func matchSoundLib(Dname):
	match Dname:
		"Koseki Bijou":
			soundToUse = $SoundLib/Biboo
		"Fuwawa":
			soundToUse = $SoundLib/Fuwa
		"Marco Juan":
			soundToUse = $SoundLib/Moco
		"Mocojan":
			soundToUse = $SoundLib/Moco
		"Mogojan":
			soundToUse = $SoundLib/Moco
		"Mococo":
			soundToUse = $SoundLib/Moco
		_:
			soundToUse = $SoundLib/Default

func _input(event):
	if event.is_action_released("Slash") and activeDialogue == true:
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


func _on_skip_pressed():
	writing = false
	$SpeakDelay.stop()
	skip = true
	proceedDialogue.emit()
	$DialoguePanel/Name.text = "Halfpot"
	$DialoguePanel/Dialogue.text = "Adios"
