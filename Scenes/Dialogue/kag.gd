extends TextureRect

const SIZE = Vector2(128, 128)

var emotions = {
	"neutral": Vector2(0,0),
	"happy": Vector2(128,0),
	"happy2": Vector2(256,0),
	"sad": Vector2(384,0),
	"shock": Vector2(512,0),
	"eugh": Vector2(640,0),
	"mad": Vector2(768,0),
	"mad2": Vector2(896,0),
	"ohno": Vector2(1024,0)
}

func set_emotion(emotion):
	var emotion_pos = emotions.get(emotion, Vector2(0, 0))
	texture.region = Rect2(emotion_pos.x, emotion_pos.y, SIZE.x, SIZE.y)
