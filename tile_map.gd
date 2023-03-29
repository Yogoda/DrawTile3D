@tool
extends Node3D

@export_category("Action")
@export var generate:bool :
	set(value):
		generate_()

@export_category("Params")

@export var default_tile_type:TileType

@export var tiles_xcount:=16
@export var tile_index:Vector2

var tile_map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func create_test_tiles():
	
	tile_map[Vector3(0, 0, 0)] = TileInstance.new(default_tile_type)

func copy_mesh(p_mesh:Mesh, p_surface_tool:SurfaceTool):
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(p_mesh, 0)

	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	for face_index in range(mesh_data_tool.get_face_count()):
		
		for vi in range(3):
			
			var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
			
			vertex = mesh_data_tool.get_vertex(vertex_index)
			normal = mesh_data_tool.get_vertex_normal(vertex_index)
			uv = mesh_data_tool.get_vertex_uv(vertex_index)
			
			uv = uv / tiles_xcount + tile_index * (1.0 / tiles_xcount)

			p_surface_tool.set_uv(uv)
			p_surface_tool.set_normal(normal)
			p_surface_tool.add_vertex(vertex)
			
	tile_index.x += 1

func generate_():
	
	print("generate geometry")
	
	create_test_tiles()
	
	var tile_type:TileType = tile_map[Vector3(0, 0, 0)].tile_type
	
	var surface_tool:SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	copy_mesh(tile_type.mesh_front, surface_tool)
	copy_mesh(tile_type.mesh_back, surface_tool)
	copy_mesh(tile_type.mesh_left, surface_tool)
	copy_mesh(tile_type.mesh_right, surface_tool)
	copy_mesh(tile_type.mesh_top, surface_tool)
	copy_mesh(tile_type.mesh_bottom, surface_tool)
	
	$Chunk.mesh = surface_tool.commit()
