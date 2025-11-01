extends Node

@export var ship_part_scene: PackedScene
@export var total_parts_to_win: int = 5
@onready var gravity_bar: TextureProgressBar = $UI/GravitationalCalibrator
@onready var parts_label: Label = $UI/PartsLabel

var current_gravity: float
var parts_collected: int = 0

func _ready():
	update_ui()

func _process(_delta):
	update_ui()

func update_ui():
	parts_label.text = "Partes: %d / %d" % [parts_collected, total_parts_to_win]
