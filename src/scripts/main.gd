extends CanvasLayer

enum StopwatchState { LAZY, RUNNING, STOPING }

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

export(Array) var spinboxes

var sw_state = StopwatchState.LAZY
var remain_time := 150.0
var score := Score.new()
var auto_range := false
var last_idx_type := 17
var indx := 0
var ifdx := 0
var spinboxes_containers := [0, 0, 0, 0, 0, 0, 0, 0]
var cameras = []
var round_media_path = ""


func _ready() -> void:
	for spin in range(spinboxes.size()):
		spinboxes[spin] = get_node(spinboxes[spin])

	scr_lbl.text = "Pontuação atual: " + str(score.calc())
	chart.initialize(
		chart.LABELS_TO_SHOW.X_LABEL + chart.LABELS_TO_SHOW.Y_LABEL, {points = Color(1.0, 1.0, 1.0)}
	)

	for i in range(17):
		data_opt.add_item("M" + str(i).pad_zeros(2))
	data_opt.add_item("Pontuação Total")
	data_opt.add_item("Tempo Total")
	data_opt.add_item("Precisão")
	data_opt.select(17)

	chick_opt.add_item("fora")
	chick_opt.add_item("parcialmente dentro")
	chick_opt.add_item("completamente dentro")
	chick_opt.select(0)


func _process(delta: float) -> void:
	if sw_state == StopwatchState.RUNNING:
		remain_time -= delta
	if remain_time <= 0:
		_on_StopwatchBtn_pressed()
	sw_val.text = str(stepify(remain_time, .001)).pad_zeros(3)


func _on_RegisterRoundBtn_pressed() -> void:
	var inst := Round.new()
	inst.set_props(score, OS.get_unix_time(), 150.0 - remain_time, round_media_path)
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
	table.text = ""
	up_stats()


func _on_StopwatchBtn_pressed() -> void:
	match sw_state:
		StopwatchState.LAZY:
			sw_btn.text = "Parar"
			sw_state = StopwatchState.RUNNING
		StopwatchState.RUNNING:
			sw_btn.text = "Resetar"
			sw_state = StopwatchState.STOPING
		StopwatchState.STOPING:
			sw_btn.text = "Iniciar"
			sw_state = StopwatchState.LAZY
			remain_time = 150


func set_score(idx: int, subidx: int, val: int) -> void:
	if subidx != -1:
		score.missions[idx][subidx] = val
	else:
		score.missions[idx] = val

	scr_lbl.text = "Pontuação atual: " + str(score.calc())


func up_stats() -> void:
	best_score_lbl.text = "Melhor pontuação: " + str(RoundDB.best_score)
	best_time_lbl.text = "Melhor tempo: " + str(stepify(RoundDB.best_time, 0.001))
	avg_score_lbl.text = (
		"Média de pontuação: "
		+ (
			str(stepify(RoundDB.total_score as float / RoundDB.rounds.size(), 0.001))
			if RoundDB.rounds.size() > 0
			else "0"
		)
	)
	avg_time_lbl.text = (
		"Média de tempo: "
		+ (
			str(stepify(RoundDB.total_time as float / RoundDB.rounds.size(), 0.001))
			if RoundDB.rounds.size() > 0
			else "0"
		)
	)
	round_count_lbl.text = ("Quantidade de Rounds: " + str(RoundDB.rounds.size()))
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
	for spin in spinboxes:
		sum += spin.value
	if sum > 8:
		value -= 1
	remain_conts.text = "Contâiners restantes: " + str(8 - sum)
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


func up_chart(_force):
	table.text = ""
	chart.clear_chart()
	if auto_range:
		idx_final.value = RoundDB.rounds.size()
	if idx_final.value - idx_init.value < 2:
		return
	if data_opt.selected == 19:
		avg_chart()
		return
	var vals := []
	var max_val := get_chart_val(idx_init.value)

	for i in range(idx_init.value, idx_final.value):
		var val := get_chart_val(i)
		vals.append(val)
		if val > max_val:
			max_val = val
	for i in range(idx_init.value, idx_final.value):
		append_round(i, vals[i - idx_init.value])


func avg_chart():
	for i in range(17):
		var max_val := Score.calc_mission(i, RoundDB.rounds[idx_init.value].score.missions[i])
		var missions_data := []
		for j in range(idx_init.value, idx_final.value):
			missions_data.append(Score.calc_mission(i, RoundDB.rounds[j].score.missions[i]))
			if missions_data[-1] > max_val: max_val = missions_data[-1]

		var sum := 0.0
		for mission_data in missions_data:
			sum += mission_data / max(max_val, 1)
		chart.create_new_point(
			{
				label = "M" + str(i).pad_zeros(2),
				values = {data = (sum / (idx_final.value - idx_init.value)) * 100 }
			}
		)
		table.text += (
			"M"
			+ str(i).pad_zeros(2)
			+ ": "
			+ str(sum / (idx_final.value - idx_init.value))
			+ "\n"
		)


func get_chart_val(idx: int) -> int:
	var data := 0
	if data_opt.selected == 17:
		data = RoundDB.rounds[idx].total_score
	elif data_opt.selected == 18:
		data = RoundDB.rounds[idx].time
	else:
		data = Score.calc_mission(
			data_opt.selected, RoundDB.rounds[idx].score.missions[data_opt.selected]
		)
	return data


func append_round(idx: int, val: int) -> void:
	chart.create_new_point(
		{label = str(idx + 1 if idx >= 0 else RoundDB.rounds.size()), values = {data = val}}
	)
	table.text += (
		"Round "
		+ str(idx + 1 if idx >= 0 else RoundDB.rounds.size())
		+ ": "
		+ str(val)
		+ "\n"
	)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	auto_range = false
	idx_init.value = 0
	idx_final.value = RoundDB.rounds.size()
	up_chart(true)
	auto_range = button_pressed


func _on_OptionButton_item_selected(_index: int) -> void:
	up_chart(true)


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
