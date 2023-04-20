@tool
class_name Tile3D

const TILE_2D_NOT_SET:int = -1

var tile_shape:TileShape

var tile_2D:int = TILE_2D_NOT_SET

#texture override
var tile_2D_up:int = TILE_2D_NOT_SET
var tile_2D_down:int = TILE_2D_NOT_SET
var tile_2D_left:int = TILE_2D_NOT_SET
var tile_2D_right:int = TILE_2D_NOT_SET
var tile_2D_forward:int = TILE_2D_NOT_SET
var tile_2D_back:int = TILE_2D_NOT_SET

func _init(p_shape:TileShape, p_tile_2D:int):
	
	tile_2D = p_tile_2D
	tile_shape = p_shape


#functions do not seem to work in Resource/Tool ?
#func get_tile_2D_top() -> Vector2i:
#		if tile_2D_top.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_top
#
#func get_tile_2D_bottom() -> Vector2i:
#		if tile_2D_bottom.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_bottom
#
#func get_tile_2D_left() -> Vector2i:
#		if tile_2D_left.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_left
#
#func get_tile_2D_right() -> Vector2i:
#		if tile_2D_right.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_right
#
#func get_tile_2D_front() -> Vector2i:
#		if tile_2D_front.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_front
#
#func get_tile_2D_back() -> Vector2i:
#		if tile_2D_back.x == -1:
#			return tile_2D
#		else:
#			return tile_2D_back

