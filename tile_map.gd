@tool
extends Node3D
class_name TileMap3D

@export_category("Action")
@export var generate:bool :
	set(value):
		
		if reset:
			create_test_tiles()
			
		generate_mesh(value)
		
@export var reset:bool = false

@export_category("Params")

@export var default_tile_shape:TileShape
var selected_tile

@export var tile_size:Vector3 = Vector3(1.0, 1.0, 1.0)
@export var tiles_xcount:=16
@export var tile_index:Vector2i

var tile_map = {}
var tile_chunks = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func create_test_tiles():
	
	tile_map.clear()
	
	var tile = Tile3D.new(default_tile_shape)
	
	set_tile(Vector3i(-1, 0, -1), tile)
	set_tile(Vector3i(-1, 0, 0), tile)
	set_tile(Vector3i(-1, 0, 1), tile)
	
	set_tile(Vector3i(-2, 0, -1), tile)
	set_tile(Vector3i(-2, 0, 0), tile)
	set_tile(Vector3i(-2, 0, 1), tile)
	
	set_tile(Vector3i(-1, 1, -1), tile)
	set_tile(Vector3i(-1, 1, 0), tile)
	set_tile(Vector3i(-1, 1, 1), tile)
	
	set_tile(Vector3i(-2, 1, -1), tile)
	set_tile(Vector3i(-2, 1, 0), tile)
	set_tile(Vector3i(-2, 1, 1), tile)
	
	set_tile(Vector3i(1, 0, -1), tile)
	set_tile(Vector3i(1, 0, 0), tile)
	set_tile(Vector3i(1, 0, 1), tile)
	
	set_tile(Vector3i(0, 0, -1), tile)
	set_tile(Vector3i(0, 0, 1), tile)

func set_tile(p_pos:Vector3i, p_tile:Tile3D = null):
	
	if p_tile == null:
		p_tile = Tile3D.new(default_tile_shape)

#	print("tile:", selected_tile)
	tile_map[p_pos] = p_tile

func copy_mesh(p_mesh:Mesh, p_surface_tool:SurfaceTool, p_tile_pos:Vector3i):
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(p_mesh, 0)

	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	#random tile
	tile_index = Vector2i(randi_range(0,15), randi_range(0,15))
	
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var face_normal = mesh_data_tool.get_face_normal(face_index)
		
		for vi in range(3):
			
			var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
			
			vertex = mesh_data_tool.get_vertex(vertex_index)
			normal = mesh_data_tool.get_vertex_normal(vertex_index)
			uv = mesh_data_tool.get_vertex_uv(vertex_index)
			
			if abs(face_normal.dot(Vector3.FORWARD)) > 0.5:
				uv.x = vertex.x
				uv.y = vertex.y
			elif abs(face_normal.dot(Vector3.UP)) > 0.5:
				uv.x = vertex.x
				uv.y = vertex.z
			else:
				uv.x = vertex.y
				uv.y = vertex.z
				
			var tile_size_ = 2.0
			uv.x = (uv.x + tile_size_ / 2.0) / tile_size_
			uv.y = (uv.y + tile_size_ / 2.0) / tile_size_
			
			#select tile index
			uv = uv / tiles_xcount + tile_index * (1.0 / tiles_xcount)
			
#			print(uv)

			vertex *= tile_size / 2.0
			vertex += (p_tile_pos as Vector3) * tile_size
			
#			vertex *= randf_range(1.0, 1.1)

			p_surface_tool.set_uv(uv)
			p_surface_tool.set_normal(normal)
			p_surface_tool.add_vertex(vertex)

@warning_ignore("unused_parameter")
func generate_mesh(value):
	
	print("generate geometry")
	
	var surface_tool:SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for tile_pos in tile_map.keys() as Array[Vector3i]:
		
		var tile_shape:TileShape = tile_map[tile_pos].tile_shape
	
		if not tile_map.has(tile_pos + Vector3i.BACK):
			copy_mesh(tile_shape.mesh_front, surface_tool, tile_pos)
			
		if not tile_map.has(tile_pos + Vector3i.FORWARD):
			copy_mesh(tile_shape.mesh_back, surface_tool, tile_pos)
			
		if not tile_map.has(tile_pos + Vector3i.RIGHT):
			copy_mesh(tile_shape.mesh_left, surface_tool, tile_pos)
			
		if not tile_map.has(tile_pos + Vector3i.LEFT):
			copy_mesh(tile_shape.mesh_right, surface_tool, tile_pos)
			
		if not tile_map.has(tile_pos + Vector3i.UP):
			copy_mesh(tile_shape.mesh_top, surface_tool, tile_pos)
			
		if not tile_map.has(tile_pos + Vector3i.DOWN):
			copy_mesh(tile_shape.mesh_bottom, surface_tool, tile_pos)
	
	var mesh:Mesh = surface_tool.commit()
	var faces:Array = mesh.surface_get_arrays(0)[0]
	
	$Chunk.mesh = mesh
	$CollisionShape3D.shape.set_faces(faces)
