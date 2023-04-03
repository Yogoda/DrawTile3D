extends Resource
class_name Tile3D

@export var tile_shape:TileShape

const TEX_INDEX_NOT_SET:Vector2i = Vector2i(-1, -1)

@export var tex_index:Vector2i = TEX_INDEX_NOT_SET

#texture override
@export var tex_index_up:Vector2i = TEX_INDEX_NOT_SET
@export var tex_index_down:Vector2i = TEX_INDEX_NOT_SET
@export var tex_index_left:Vector2i = TEX_INDEX_NOT_SET
@export var tex_index_right:Vector2i = TEX_INDEX_NOT_SET
@export var tex_index_forward:Vector2i = TEX_INDEX_NOT_SET
@export var tex_index_back:Vector2i = TEX_INDEX_NOT_SET

#functions do not seem to work in Resource/Tool ?
#func get_tex_index_top() -> Vector2i:
#		if tex_index_top.x == -1:
#			return tex_index
#		else:
#			return tex_index_top
#
#func get_tex_index_bottom() -> Vector2i:
#		if tex_index_bottom.x == -1:
#			return tex_index
#		else:
#			return tex_index_bottom
#
#func get_tex_index_left() -> Vector2i:
#		if tex_index_left.x == -1:
#			return tex_index
#		else:
#			return tex_index_left
#
#func get_tex_index_right() -> Vector2i:
#		if tex_index_right.x == -1:
#			return tex_index
#		else:
#			return tex_index_right
#
#func get_tex_index_front() -> Vector2i:
#		if tex_index_front.x == -1:
#			return tex_index
#		else:
#			return tex_index_front
#
#func get_tex_index_back() -> Vector2i:
#		if tex_index_back.x == -1:
#			return tex_index
#		else:
#			return tex_index_back

func _init(p_tex_index:Vector2i, p_shape:TileShape):
	
	tex_index = p_tex_index
	tile_shape = p_shape
