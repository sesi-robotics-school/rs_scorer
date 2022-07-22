extends CanvasLayer

enum SwState { LAZY, RUNNING, STOPING }

export(NodePath) onready var sw_btn = get_node(sw_btn)
export(NodePath) onready var sw_val = get_node(sw_val)
export(NodePath) onready var scr_lbl = get_node(scr_lbl)
export(NodePath) onready var best_score_lbl = get_node(best_score_lbl)
export(NodePath) onready var best_time_lbl = get_node(best_time_lbl)
export(NodePath) onready var avg_score_lbl = get_node(avg_score_lbl)
export(NodePath) onready var avg_time_lbl = get_node(avg_time_lbl)
export(NodePath) onready var round_count_lbl = get_node(round_count_lbl)
export(NodePath) onready var chart = get_node("Margin/HBox/VBoxContainer/ReferenceRect/GDCharts")
export(NodePath) onready var idx_init = get_node(idx_init)
export(NodePath) onready var idx_final = get_node(idx_final)
export(NodePath) onready var data_opt = get_node(data_opt)
export(NodePath) onready var remain_conts = get_node(remain_conts)
export(NodePath) onready var chick_opt = get_node(chick_opt)
export(NodePath) onready var table = get_node(table)
export(NodePath) onready var spin_round_med = get_node(spin_round_med)
export(NodePath) onready var round_name = get_node(round_name)

export(Array) var spinboxes: Array

var sw_state = SwState.LAZY
var remain_time := 150.0
var score := Score.new()
var auto_range := false
var last_idx_type := 17
var indx := 0
var ifdx := 0
var spinboxes_containers := [0, 0, 0, 0, 0, 0, 0, 0]
var cameras := []
var round_media_path := ""
var filter := RegEx.new()

func _ready() -> void:
	filter.compile(".*")
	for spin in range(spinboxes.size()):
		spinboxes[spin] = get_node(spinboxes[spin])

	scr_lbl.text = "Total Score: " + str(score.calc())
	chart.initialize(
		chart.LABELS_TO_SHOW.X_LABEL + chart.LABELS_TO_SHOW.Y_LABEL, {points = Color(1.0, 1.0, 1.0)}
	)

	for i in range(17):
		data_opt.add_item("M" + str(i).pad_zeros(2))
	data_opt.add_item("Total Score")
	data_opt.add_item("Time")
	data_opt.add_item("Precision")
	data_opt.select(17)

	chick_opt.add_item("out")
	chick_opt.add_item("parcially inside")
	chick_opt.add_item("completally inside")
	chick_opt.select(0)


func _process(delta: float) -> void:
	if sw_state == SwState.RUNNING:
		remain_time -= delta
	if remain_time <= 0:
		_on_StopwatchBtn_pressed()
	sw_val.text = str(stepify(remain_time, .001)).pad_zeros(3)


func _on_RegisterRoundBtn_pressed() -> void:
	var inst := Round.new()
	inst.set_props(score, OS.get_unix_time(), 150.0 - remain_time, round_media_path, round_name.text)
	RoundDB.inc_round(inst)
	up_stats()
	up_chart(false)

func _on_ClearBtn_pressed() -> void:
	RoundDB.rounds = []
	RoundDB.best_score = 0
	RoundDB.best_time = 0
	RoundDB.total_score = 0
	RoundDB.total_time = 0
	chart.clear_chart()
	table.bbcode_text = ""
	up_stats()


func _on_StopwatchBtn_pressed() -> void:
	match sw_state:
		SwState.LAZY:
			sw_btn.text = "Stop"
			sw_state = SwState.RUNNING
		SwState.RUNNING:
			sw_btn.text = "Reset"
			sw_state = SwState.STOPING
		SwState.STOPING:
			sw_btn.text = "Start"
			sw_state = SwState.LAZY
			remain_time = 150


func set_score(idx: int, subidx: int, val: int) -> void:
	if subidx != -1:
		score.missions[idx][subidx] = val
	else:
		score.missions[idx] = val

	scr_lbl.text = "Total Score: " + str(score.calc())


func up_stats() -> void:
	best_score_lbl.text = "Highest score: " + str(RoundDB.best_score)
	best_time_lbl.text = "Best time: " + str(stepify(RoundDB.best_time, 0.001))
	avg_score_lbl.text = (
		"Score Mean: "
		+ (
			str(stepify(RoundDB.total_score as float / RoundDB.rounds.size(), 0.001))
			if RoundDB.rounds.size() > 0
			else "0"
		)
	)
	avg_time_lbl.text = (
		"Time Mean: "
		+ (
			str(stepify(RoundDB.total_time as float / RoundDB.rounds.size(), 0.001))
			if RoundDB.rounds.size() > 0
			else "0"
		)
	)
	round_count_lbl.text = ("Round Count: " + str(RoundDB.rounds.size()))
	idx_final.max_value = RoundDB.rounds.size()
	spin_round_med.max_value = RoundDB.rounds.size()

### Scoring

func _on_M00_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(0, -1, button_pressed)


func _on_M01_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(1, -1, button_pressed)


func _on_M02_SpinBox_value_changed(value: float) -> void:
	set_score(2, 0, int(value))


func _on_M02_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(2, 1, button_pressed)


func _on_M03_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(3, 0, button_pressed)


func _on_M03_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(3, 1, button_pressed)


func _on_M04_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(4, 0, button_pressed)


func _on_M04_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(4, 1, button_pressed)


func _on_M05_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(5, -1, button_pressed)


func _on_M06_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(6, 0, button_pressed)


func _on_M06_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(6, 1, button_pressed)


func _on_M07_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(7, 0, button_pressed)


func _on_M07_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(7, 1, button_pressed)


func _on_M08_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(8, 0, button_pressed)


func _on_M08_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(8, 1, button_pressed)


func _on_M09_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(9, 0, button_pressed)


func _on_M09_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(9, 1, button_pressed)


func _on_M10_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(10, -1, button_pressed)


func _on_M11_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(11, 0, button_pressed)


func _on_M11_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(11, 1, button_pressed)


func _on_M12_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(12, 0, button_pressed)


func _on_M12_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(12, 1, button_pressed)


func _on_M12_CheckBox3_toggled(button_pressed: bool) -> void:
	set_score(12, 2, button_pressed)


func _on_M13_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(13, 0, button_pressed)


func _on_M13_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(13, 1, button_pressed)


func _on_M13_CheckBox3_toggled(button_pressed: bool) -> void:
	set_score(13, 2, button_pressed)


func _on_M14_SpinBox_value_changed(value: float) -> void:
	set_score(14, -1, int(value))


func _on_M17_SpinBox_value_changed(value: float) -> void:
	set_score(17, -1, int(value))


func up_container(contidx: int, value: int) -> void:
	var sum := 0
	for spin in spinboxes: sum += spin.value
	if sum > 8: value -= 1
	remain_conts.text = "Remaining Containers " + str(8 - sum)
	spinboxes[contidx].value = value
	spinboxes_containers[contidx] = value


func _on_M15_SpinBox_value_changed(value: float) -> void:
	up_container(0, int(value))
	set_score(15, 0, int(value))


func _on_M15_SpinBox2_value_changed(value: float) -> void:
	up_container(1, int(value))
	set_score(15, 1, int(value))


func _on_M15_SpinBox3_value_changed(value: float) -> void:
	up_container(2, int(value))
	set_score(15, 2, int(value))


func _on_M16_SpinBox_value_changed(value: float) -> void:
	up_container(3, int(value))
	set_score(16, 0, int(value))


func _on_M16_SpinBox2_value_changed(value: float) -> void:
	up_container(4, int(value))
	set_score(16, 1, int(value))


func _on_M16_CheckBox_toggled(button_pressed: bool) -> void:
	set_score(16, 2, button_pressed)


func _on_M16_CheckBox2_toggled(button_pressed: bool) -> void:
	set_score(16, 3, button_pressed)


func _on_M16_SpinBox3_value_changed(value: float) -> void:
	set_score(16, 4, int(value))


func up_chart(_x):
	if auto_range: idx_final.value = RoundDB.rounds.size()
	if idx_final.value - idx_init.value < 2: return
	if data_opt.selected == 19: return rnd_avg_chart()
	
	var rounds := []
	var max_val := 0
	for i in range(idx_init.value, idx_final.value):
		var rd = RoundDB.rounds[i]
		if filter.search(rd.name) != null:
			rounds.append(i)
			var chart_val := get_chart_val(i)
			max_val = max(max_val, chart_val)
	rnd_chart(rounds, max_val)

func rnd_avg_chart():
	table.bbcode_text = ""
	chart.clear_chart()
	chart.max_value = 100
	for i in range(17):
		var max_val := Score.calc_mission(i, RoundDB.rounds[idx_init.value].score.missions[i])
		var missions_data := []
		for j in range(idx_init.value, idx_final.value):
			missions_data.append(Score.calc_mission(i, RoundDB.rounds[j].score.missions[i]))
			if missions_data[-1] > max_val: max_val = missions_data[-1]

		var sum := 0.0
		for mission_data in missions_data:
			sum += mission_data / max(max_val, 1)
		var med: float = sum / (idx_final.value - idx_init.value)
		chart.create_new_point(
			{
				label = "M" + str(i).pad_zeros(2),
				values = {data = med * 100 }
			}
		)
		table.bbcode_text += (
			"M %s: %s\n" % [str(i).pad_zeros(2), str(med)]
		)

func rnd_chart(values: PoolIntArray, max_val: int):
	table.bbcode_text = ""
	chart.clear_chart()
	var med := max_val / max(values.size(), 1) as float
	var sum := 0
	for i in values:
		var rdv = get_chart_val(i)
		sum += rdv
		append_round(i, get_chart_val(i), med)
	table.bbcode_text += (
		"Mean: " + str(sum / values.size() as float)
	)

func get_chart_val(idx: int) -> int:
	match data_opt.selected:
		17: return RoundDB.rounds[idx].total_score
		18: return RoundDB.rounds[idx].time
		_: return Score.calc_mission(
			data_opt.selected, RoundDB.rounds[idx].score.missions[data_opt.selected]
		)


func append_round(idx: int, val: int, med: float) -> void:
	chart.create_new_point(
		{label = str(idx if idx >= 0 else RoundDB.rounds.size()), values = {data = val}}
	)
	var color := Color(1, 1, 1)
	
	if val > med: color = color.linear_interpolate(Color.green, val / med as float - 1)
	elif val == 0: color = Color.red
	elif val < med - 10: color = color.linear_interpolate(Color.red, med / val as float - 1)
	
	table.bbcode_text += (
		"[color=#{color}]Round {name}: {score}[/color]\n".format({
			"color": color.to_html(),
			"name": str(idx if idx >= 0 else RoundDB.rounds.size()),
			"score": str(val)
		})
	)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	print_stack()
	auto_range = false
	idx_init.value = 0
	idx_final.value = RoundDB.rounds.size()
	up_chart(false)
	auto_range = button_pressed


func _on_OptionButton_item_selected(_index: int) -> void:
	up_chart(false)


func _on_M12_OptionButton_item_selected(index: int) -> void:
	set_score(12, 2, index > 0)
	set_score(12, 3, index > 1)


func _on_UndoRound_pressed():
	RoundDB.rounds.pop_back()
	up_stats()


func _on_SetRoudVideo_pressed():
	$FileDialog.show()


func _on_FileDialog_file_selected(path):
	round_media_path = path


func _on_Button_pressed():
	var idx := spin_round_med.value as int
	if File.new().file_exists(RoundDB.rounds[idx].round_media_path):
		if OS.shell_open(RoundDB.rounds[idx].round_media_pathe) != OK:
			print('Error opening round media file')
	else:
		$AcceptDialog.show()


func _on_LineEdit_text_entered(new_text):
	filter = RegEx.new()
	var err := filter.compile(new_text)
	if err != OK:
		push_error("Error compiling regex round filter: " + str(err))
	up_chart(false)
