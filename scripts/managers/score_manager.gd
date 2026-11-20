class_name ScoreManager
extends RefCounted
## Tracks current score, persistent high scores (overall and per-difficulty), and game settings.

const SECTION_SCORES: String = "scores"
const SECTION_SETTINGS: String = "settings"

var save_path: String
var current_score: int = 0
var high_score: int = 0
var difficulty: GameConfig.Difficulty = GameConfig.Difficulty.NORMAL
var wrap_walls: bool = false
var sfx_enabled: bool = true
var music_enabled: bool = true
var classic_dpad: bool = false

var _difficulty_high_scores: Dictionary = {
	GameConfig.Difficulty.EASY: 0,
	GameConfig.Difficulty.NORMAL: 0,
	GameConfig.Difficulty.HARD: 0,
}


func _init(p_save_path: String = GameConfig.SAVE_FILE_PATH) -> void:
	save_path = p_save_path
	load_data()


func reset_score() -> void:
	current_score = 0


func add_points(points: int = GameConfig.POINTS_PER_FOOD) -> bool:
	if points <= 0:
		return false

	current_score += points
	var is_new_record: bool = false

	var diff_best: int = get_high_score_for(difficulty)
	if current_score > diff_best:
		_difficulty_high_scores[difficulty] = current_score
		is_new_record = true

	if current_score > high_score:
		high_score = current_score
		is_new_record = true

	if is_new_record:
		save_data()

	return is_new_record


func set_difficulty(new_difficulty: GameConfig.Difficulty) -> void:
	if new_difficulty not in GameConfig.DIFFICULTY_INTERVALS:
		return
	difficulty = new_difficulty
	save_data()


func set_wrap_walls(enabled: bool) -> void:
	wrap_walls = enabled
	save_data()


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	save_data()


func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	save_data()


func set_classic_dpad(enabled: bool) -> void:
	classic_dpad = enabled
	save_data()


func get_move_interval() -> float:
	return GameConfig.get_move_interval(difficulty)


func get_high_score_for(diff: GameConfig.Difficulty) -> int:
	return int(_difficulty_high_scores.get(diff, 0))


func save_data() -> Error:
	var config := ConfigFile.new()
	config.set_value(SECTION_SCORES, "high_score", high_score)
	config.set_value(SECTION_SCORES, "easy_high", get_high_score_for(GameConfig.Difficulty.EASY))
	config.set_value(SECTION_SCORES, "normal_high", get_high_score_for(GameConfig.Difficulty.NORMAL))
	config.set_value(SECTION_SCORES, "hard_high", get_high_score_for(GameConfig.Difficulty.HARD))
	config.set_value(SECTION_SETTINGS, "difficulty", int(difficulty))
	config.set_value(SECTION_SETTINGS, "wrap_walls", wrap_walls)
	config.set_value(SECTION_SETTINGS, "sfx_enabled", sfx_enabled)
	config.set_value(SECTION_SETTINGS, "music_enabled", music_enabled)
	config.set_value(SECTION_SETTINGS, "classic_dpad", classic_dpad)
	return config.save(save_path)


func load_data() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return

	high_score = maxi(0, int(config.get_value(SECTION_SCORES, "high_score", 0)))
	_difficulty_high_scores[GameConfig.Difficulty.EASY] = maxi(0, int(config.get_value(SECTION_SCORES, "easy_high", 0)))
	_difficulty_high_scores[GameConfig.Difficulty.NORMAL] = maxi(0, int(config.get_value(SECTION_SCORES, "normal_high", 0)))
	_difficulty_high_scores[GameConfig.Difficulty.HARD] = maxi(0, int(config.get_value(SECTION_SCORES, "hard_high", 0)))

	var saved_diff: int = int(config.get_value(SECTION_SETTINGS, "difficulty", int(GameConfig.Difficulty.NORMAL)))
	if saved_diff in GameConfig.DIFFICULTY_INTERVALS:
		difficulty = saved_diff as GameConfig.Difficulty
	else:
		difficulty = GameConfig.Difficulty.NORMAL

	wrap_walls = bool(config.get_value(SECTION_SETTINGS, "wrap_walls", false))
	sfx_enabled = bool(config.get_value(SECTION_SETTINGS, "sfx_enabled", true))
	music_enabled = bool(config.get_value(SECTION_SETTINGS, "music_enabled", true))
	classic_dpad = bool(config.get_value(SECTION_SETTINGS, "classic_dpad", false))
