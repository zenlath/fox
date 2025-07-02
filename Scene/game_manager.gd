extends Node

const SAVE_FILE_PATH := "user://save_game.dat"

var saved_position: Vector2 = Vector2.ZERO

func save_position(position: Vector2) -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(position)
	file.close()
	print("Game saved at:", position)

func load_position() -> Vector2:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		var pos = file.get_var()
		file.close()
		print("Game loaded at:", pos)
		return pos
	else:
		print("No save file found.")
		return Vector2.ZERO
