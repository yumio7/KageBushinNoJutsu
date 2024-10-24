extends TextureRect

const SIZE = Vector2(128, 128)

var sprite = 0

var emotions = {
	"neutral": 0,
	"happy": 128,
	"happy2": 256,
	"sad": 384,
	"shock": 512,
	"eugh": 640,
	"mad": 768,
	"mad2": 896,
	"ohno": 1024
}

func set_emotion(emotion):
	var emotion_pos = Vector2(emotions.get(emotion), sprite)
	texture.region = Rect2(emotion_pos.x, emotion_pos.y, SIZE.x, SIZE.y)

func set_sprite(char_name):
	match char_name:
		"Kagerou":
			sprite = 0
		"Nazrin":
			sprite = 128
		"Seija":
			sprite = 256
