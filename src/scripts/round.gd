extends Resource
class_name Round

var score := Score.new()
var total_score := 0
var time := 150.0
var unix_time := 0
var round_media_path := ""


func set_props(_score: Score, _unix_time: int, _time: float, _round_media_path: String):
	score = _score
	total_score = _score.calc()
	unix_time = _unix_time
	time = _time
	round_media_path = _round_media_path


func as_json() -> String:
	return to_json([score.as_json(), var2str(unix_time), var2str(time), round_media_path])


func _ready() -> void:
	pass


func date() -> String:
	var dict := OS.get_datetime_from_unix_time(unix_time)
	return (
		"%d/%d/%d %d:%d:%d"
		% [dict["year"], dict["month"], dict["day"], dict["hour"], dict["minute"], dict["second"]]
	)
