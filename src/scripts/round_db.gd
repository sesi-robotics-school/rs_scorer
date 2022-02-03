extends Node

var db_reader := File.new()
var db_writer := File.new()
var db_reader_thread := Thread.new()

var rounds := []

var best_score := 0
var best_time := 150.0
var total_score := 0
var total_time := 0.0

onready var main_scn := $"/root/Main"


func _ready() -> void:
	var err := db_reader_thread.start(self, "check_db")
	if err != OK:
		print("An error ocurred while initializing db reader thread: ", err)


func check_db() -> void:
	var srt := OS.get_ticks_msec()
	if db_reader.file_exists("user://round_history.zstd"):
		var err := db_reader.open_compressed(
			"user://round_history.zstd", File.READ, File.COMPRESSION_ZSTD
		)
		if err != OK:
			push_error("Error opening db file: " + String(err))
			return
		else:
			while not db_reader.eof_reached():
				add_round_json(db_reader.get_line())
		db_reader.close()
	var end := OS.get_ticks_msec()
	print("Elapsed time to initialize: ", end - srt, "ms")
	print("Round count: ", rounds.size())


func add_round_json(text: String) -> void:
	var roundjs := JSON.parse(text)
	if roundjs.error != OK:
		push_error("Error parsing json: " + str(roundjs.error) + ": " + text)
		return
	var rs := Round.new()

	var err := rs.score.from_json(roundjs.result[0])
	if err != OK:
		push_error("Error parsing score properties: " + str(err))
	
	if roundjs.result.size() < 4: return

	rs.set_props(rs.score, str2var(roundjs.result[1]), str2var(roundjs.result[2]) as float, roundjs.result[3])
	inc_round(rs)
	main_scn.call_deferred("up_stats")


func _exit_tree() -> void:
	var srt := OS.get_ticks_msec()
	db_reader_thread.wait_to_finish()
	var err := db_writer.open_compressed(
		"user://round_history.zstd", File.WRITE, File.COMPRESSION_ZSTD
	)
	if err != OK:
		push_error("Error saving db file: " + String(err))
	for fll_round in rounds:
		db_writer.store_line(fll_round.as_json())
	db_writer.close()
	var end := OS.get_ticks_msec()
	print("Elapsed time to save: ", end - srt, "ms")


func inc_round(new_round: Round) -> void:
	total_score += new_round.total_score
	total_time += new_round.time
	if new_round.total_score > best_score:
		best_score = new_round.total_score
	if new_round.time < best_time:
		best_time = new_round.time
	rounds.append(new_round)
