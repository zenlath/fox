extends Control

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scene/game.tscn")  # ganti dengan scene levelmu

func _on_settings_pressed():
	print("Settings belum dibuat")  # atau buka scene Settings

func _on_quit_pressed():
	get_tree().quit()
