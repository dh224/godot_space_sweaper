extends Node2D

# Paths to the Marker2D nodes defining the orbit Y positions
@export var high_orbit_marker_path: NodePath
@export var mid_orbit_marker_path: NodePath
@export var low_orbit_marker_path: NodePath


var low_orbit_spawn_point : Vector2
var mid_orbit_spawn_point : Vector2
var high_orbit_spawn_point : Vector2
var lane_y_positions : Array
var lane_positions : Array[Vector2]


func _ready() -> void:
	pass
	#var high_marker = get_node_or_null(high_orbit_marker_path)
	#var mid_marker = get_node_or_null(mid_orbit_marker_path)
	#var low_marker = get_node_or_null(low_orbit_marker_path)
	#lane_y_positions = [
		#high_marker.global_position.y,
		#mid_marker.global_position.y,
		#low_marker.global_position.y
	#]
	#lane_positions = [
		#Vector2(1300, high_marker.global_position.y),
		#Vector2(1300, mid_marker.global_position.y),
		#Vector2(1300, low_marker.global_position.y),
	#]
