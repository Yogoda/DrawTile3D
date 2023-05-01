@tool
extends Node3D
class_name TileMap3D

class Bounds:
	extends RefCounted
	
	var min:Vector3
	var max:Vector3
	
	func _init(p_min:Vector3, p_max:Vector3):
		min = p_min
		max = p_max
		
	func is_in_bounds(p:Vector3):
		
		return  p.x >= min.x and p.x <= max.x and \
				p.y >= min.y and p.y <= max.y and \
				p.z >= min.z and p.z <= max.z

@export_category("Action")

@export var generate:bool :
	set(value):
		
		if reset:
			create_test_tiles()
			
#		generate_mesh(value)

@export var reset:bool = false

@export_category("Params")

@export var tile_size:Vector3 = Vector3(1.0, 1.0, 1.0)
@export var tiles_xcount:=16

var tile_map = {}

var tile_chunks = {}

var tile_shape_cube:TileShape = preload("res://addons/dungeon_digger/tile_shapes/block/cube.tile_shape.tres")

var dd_panel:DungeonDiggerPanel

var selected_tile_2D:int
var selected_tile_3D:Tile3D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_meta("_edit_lock_", true)
	set_meta("_edit_group_", true)
	

func get_selected_tile_2D():
	
	if dd_panel == null:
		dd_panel = get_tree().get_meta("__dungeon_digger_panel")
		
	return dd_panel.selected_tile_2D

func create_test_tiles():
	
	var mesh:Mesh = load("res://starting_mesh.mesh.res")
	$Chunk.mesh = mesh.duplicate()
	
	#set collision
	var faces:Array = mesh.surface_get_arrays(0)[0]
	$CollisionShape3D.shape.set_faces(faces)
	
#	tile_map.clear()
#	tile_map_data.tile_map.clear()
	
#	var tile_2D:int
	
#	print("selected tile:", dd_panel.selected_tile_2D)
	
#	selected_tile_3D = Tile3D.new(tile_shape_cube, dd_panel.selected_tile_2D)
	
#	var tile = get_selected_tile_2D()
#
#	set_tile_3D(Vector3i(-1, 0, -1), tile)
#	set_tile_3D(Vector3i(-1, 0, 0), tile)
#	set_tile_3D(Vector3i(-1, 0, 1), tile)
#
#	set_tile_3D(Vector3i(-2, 0, -1), tile)
#	set_tile_3D(Vector3i(-2, 0, 0), tile)
#	set_tile_3D(Vector3i(-2, 0, 1), tile)
#
#	set_tile_3D(Vector3i(-1, 1, -1), tile)
#	set_tile_3D(Vector3i(-1, 1, 0), tile)
#	set_tile_3D(Vector3i(-1, 1, 1), tile)
#
#	set_tile_3D(Vector3i(-2, 1, -1), tile)
#	set_tile_3D(Vector3i(-2, 1, 0), tile)
#	set_tile_3D(Vector3i(-2, 1, 1), tile)
#
#	set_tile_3D(Vector3i(1, 0, -1), tile)
#	set_tile_3D(Vector3i(1, 0, 0), tile)
#	set_tile_3D(Vector3i(1, 0, 1), tile)
#
#	set_tile_3D(Vector3i(0, 0, -1), tile)
#	set_tile_3D(Vector3i(0, 0, 1), tile)



func coord_to_tile_pos(p_coord:Vector3) -> Vector3i:
	
	var tile_pos = p_coord
	
	tile_pos = (tile_pos + tile_size / 2.0) / tile_size
#						print("selected tile:", selected_tile)
	tile_pos = tile_pos.floor()
#							print("selected tile:", selected_tile)
	return tile_pos as Vector3i

func set_block(p_pos:Vector3i, p_tile:int):
	
	update_mesh(p_pos, p_tile)
	
#	var tile_3D = Tile3D.new(tile_shape_cube, p_tile)

#	tile_map[p_pos] = tile_3D
#	tile_map_data.tile_map[p_pos] = tile_3D
	
func remove_block(p_pos:Vector3i, p_tile:int):
	
#	tile_map.erase(p_pos)
	update_mesh(p_pos, p_tile)

func set_tile_2D(p_tile_pos:Vector3i, p_face:Vector3i):
	
	var dd_panel:DungeonDiggerPanel = get_tree().get_meta("__dungeon_digger_panel")

	var tile_2D = dd_panel.selected_tile_2D
	
	match p_face:
		Vector3i.DOWN:
			tile_map[p_tile_pos].tile_2D_down = tile_2D
		Vector3i.UP:
			tile_map[p_tile_pos].tile_2D_up = tile_2D
		Vector3i.LEFT:
			tile_map[p_tile_pos].tile_2D_left = tile_2D
		Vector3i.RIGHT:
			tile_map[p_tile_pos].tile_2D_right = tile_2D
		Vector3i.BACK:
			tile_map[p_tile_pos].tile_2D_back = tile_2D
		Vector3i.FORWARD:
			tile_map[p_tile_pos].tile_2D_forward = tile_2D

func copy_mesh(p_mesh_to_copy:Mesh, 
				p_surface_tool:SurfaceTool, 
				p_tile_pos:Vector3i, 
				p_tile_2D:int):
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(p_mesh_to_copy, 0)

	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var face_normal = mesh_data_tool.get_face_normal(face_index)
		
		for vi in range(3):
			
			var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
			
			vertex = mesh_data_tool.get_vertex(vertex_index)
			normal = mesh_data_tool.get_vertex_normal(vertex_index)
			uv = mesh_data_tool.get_vertex_uv(vertex_index)
			
			#set uv according to triangle direction
			if face_normal.dot(Vector3.FORWARD) > 0.5:
				uv.x = vertex.y
				uv.y = vertex.x
			elif face_normal.dot(Vector3.BACK) > 0.5:
				uv.x = vertex.y
				uv.y = -vertex.x
			elif face_normal.dot(Vector3.LEFT) > 0.5:
				uv.x = vertex.y
				uv.y = -vertex.z
			elif face_normal.dot(Vector3.RIGHT) > 0.5:
				uv.x = vertex.y
				uv.y = vertex.z
			else:
				uv.x = vertex.x
				uv.y = vertex.z
				
			var tile_size_ = 2.0
			uv.x = (uv.x + tile_size_ / 2.0) / tile_size_
			uv.y = (uv.y + tile_size_ / 2.0) / tile_size_
			
			var tile_2D_x = p_tile_2D % tiles_xcount
			var tile_2D_y = floor(p_tile_2D / tiles_xcount)
			
			#tile coordinate
			uv.x = uv.x / tiles_xcount + tile_2D_y * (1.0 / tiles_xcount)
			uv.y = uv.y / tiles_xcount + tile_2D_x * (1.0 / tiles_xcount)
			
#			print(uv)

			vertex *= tile_size / 2.0
			vertex += (p_tile_pos as Vector3) * tile_size
			
			p_surface_tool.set_uv(uv)
			p_surface_tool.set_normal(normal)
			p_surface_tool.add_vertex(vertex)

func get_tile_tex(p_tile:Tile3D, p_face:Vector3i) -> int:
	
	var tile_2D:int
	
	match p_face:
		Vector3i.DOWN:
			tile_2D = p_tile.tile_2D_down
		Vector3i.UP:
			tile_2D = p_tile.tile_2D_up
		Vector3i.LEFT:
			tile_2D = p_tile.tile_2D_left
		Vector3i.RIGHT:
			tile_2D = p_tile.tile_2D_right
		Vector3i.BACK:
			tile_2D = p_tile.tile_2D_back
		Vector3i.FORWARD:
			tile_2D = p_tile.tile_2D_forward
			
	if tile_2D == -1:
		return p_tile.tile_2D
		
	return tile_2D
	
	
func get_block_bounds(p_pos:Vector3i) -> Bounds:
	
	var margin = 0.01
	
	var min:Vector3 = Vector3.ZERO - tile_size / 2.0
	var max:Vector3 = Vector3.ZERO + tile_size / 2.0
	
	min -= tile_size * margin
	max += tile_size * margin
	
	min += tile_size * (p_pos as Vector3)
	max += tile_size * (p_pos as Vector3)
	
	return Bounds.new(min, max)
	
func create_block_face(p_surface_tool:SurfaceTool, p_block_pos:Vector3i, p_face:Vector3i, p_tile_2D:int):
	
	var tile_shape:TileShape = tile_shape_cube

	if p_face == Vector3i.LEFT:
		copy_mesh(tile_shape.mesh_right, p_surface_tool, p_block_pos, p_tile_2D)
	if p_face == Vector3i.RIGHT:
		copy_mesh(tile_shape.mesh_left, p_surface_tool, p_block_pos, p_tile_2D)
	if p_face == Vector3i.UP:
		copy_mesh(tile_shape.mesh_up, p_surface_tool, p_block_pos, p_tile_2D)
	if p_face == Vector3i.DOWN:
		copy_mesh(tile_shape.mesh_down, p_surface_tool, p_block_pos, p_tile_2D)
	if p_face == Vector3i.BACK:
		copy_mesh(tile_shape.mesh_forward, p_surface_tool, p_block_pos, p_tile_2D)
	if p_face == Vector3i.FORWARD:
		copy_mesh(tile_shape.mesh_back, p_surface_tool, p_block_pos, p_tile_2D)

	
func update_mesh(p_block_pos:Vector3i, p_tile_2D:int):
	
	#source mesh
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface($Chunk.mesh, 0)
	
	#new mesh
	var surface_tool:SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	#the bounds of the updated block to search faces
	var block_bounds = get_block_bounds(p_block_pos)
	#remember found block directions
	var block_faces:Array = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.BACK, Vector3i.FORWARD]
	
	#TRIANGLES
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var face_normal = mesh_data_tool.get_face_normal(face_index)
		
		var face_in_bounds:bool = true
		
		#is the face in update bounds ? (do not copy)
		for vi in range(3):
			
			var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
			
			vertex = mesh_data_tool.get_vertex(vertex_index)
			
			if not block_bounds.is_in_bounds(vertex):
				face_in_bounds = false
				break
		
		#face in modification bounds, do not copy, remember direction
		if face_in_bounds:
			
			const normal_dir_match:= 0.5
			
#			print("face normal:", face_normal)
			
			if face_normal.dot(Vector3.LEFT) > normal_dir_match:
				block_faces.erase(Vector3i.LEFT)
			elif face_normal.dot(Vector3.RIGHT) > normal_dir_match:
				block_faces.erase(Vector3i.RIGHT)
			elif face_normal.dot(Vector3.DOWN) > normal_dir_match:
				block_faces.erase(Vector3i.DOWN)
			elif face_normal.dot(Vector3.UP) > normal_dir_match:
				block_faces.erase(Vector3i.UP)
			elif face_normal.dot(Vector3.FORWARD) > normal_dir_match:
				block_faces.erase(Vector3i.FORWARD)
			elif face_normal.dot(Vector3.BACK) > normal_dir_match:
				block_faces.erase(Vector3i.BACK)
			
#			for vi in range(3):
#
#				var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
#
#				vertex = mesh_data_tool.get_vertex(vertex_index)
#				normal = mesh_data_tool.get_vertex_normal(vertex_index)
#				uv = mesh_data_tool.get_vertex_uv(vertex_index)
#
#				uv.x = 0.0
#				uv.y = 0.0
#				surface_tool.set_uv(uv)
#				surface_tool.set_normal(normal)
#				surface_tool.add_vertex(vertex)
			
		#face not in modification bounds, copy
		else:

			#TRIANGLE VERICES
			for vi in range(3):
				
				var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
				
				vertex = mesh_data_tool.get_vertex(vertex_index)
				normal = mesh_data_tool.get_vertex_normal(vertex_index)
				uv = mesh_data_tool.get_vertex_uv(vertex_index)
				
				surface_tool.set_uv(uv)
				surface_tool.set_normal(normal)
				surface_tool.add_vertex(vertex)
	
	#faces to create
	for face in block_faces:
#		print("face to create:", face)
		create_block_face(surface_tool, p_block_pos, face, p_tile_2D)
		
	#create missing faces
#	create_faces(p_block_pos, p_face:Vector3i, p_tile_2D)
	
	#set mesh
	var mesh:Mesh = surface_tool.commit()
	$Chunk.mesh = mesh
	
	#set collision
	var faces:Array = mesh.surface_get_arrays(0)[0]
	$CollisionShape3D.shape.set_faces(faces)

@warning_ignore("unused_parameter")
func generate_mesh(value):
	
	var surface_tool:SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	#tile positions
	for tile_pos in tile_map.keys() as Array[Vector3i]:
		
		var tile:Tile3D = tile_map[tile_pos] as Tile3D

		var tile_shape:TileShape = tile.tile_shape

		if not tile_map.has(tile_pos + Vector3i.LEFT):
			copy_mesh(tile_shape.mesh_right, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.LEFT))
	
		if not tile_map.has(tile_pos + Vector3i.RIGHT):
			copy_mesh(tile_shape.mesh_left, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.RIGHT))
			
		if not tile_map.has(tile_pos + Vector3i.UP):
			copy_mesh(tile_shape.mesh_up, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.UP))
			
		if not tile_map.has(tile_pos + Vector3i.DOWN):
			copy_mesh(tile_shape.mesh_down, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.DOWN))
			
		if not tile_map.has(tile_pos + Vector3i.BACK):
			copy_mesh(tile_shape.mesh_forward, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.BACK))
			
		if not tile_map.has(tile_pos + Vector3i.FORWARD):
			copy_mesh(tile_shape.mesh_back, surface_tool, tile_pos, get_tile_tex(tile, Vector3i.FORWARD))
	
	#set mesh
	var mesh:Mesh = surface_tool.commit()
	$Chunk.mesh = mesh
		
	#set collision
	var faces:Array = mesh.surface_get_arrays(0)[0]
	$CollisionShape3D.shape.set_faces(faces)
	
#	print("geometry generated")

func set_pixel(p_pos:Vector2i, color:Color):
	
	var material:StandardMaterial3D = $Chunk.material_override
	var texture:Texture2D = material.albedo_texture
	#get a copy of the image
	var image:Image = texture.get_image()

	image.set_pixel(p_pos.x, p_pos.y, color)
#	print("set pixel:", p_pos.x, " ", p_pos.y, " ", color)
	
#	texture_2d_update
	RenderingServer.texture_2d_update(texture.get_rid(), image, 0)

	var image_texture = ImageTexture.create_from_image(image)

	var err = ResourceSaver.save(image_texture, "atlas.image_texture.res")

func get_pixel(p_pos:Vector2i) -> Color:
	
	var material:StandardMaterial3D = $Chunk.material_override
	var texture:Texture2D = material.albedo_texture
	#get a copy of the image
	var image:Image = texture.get_image()

	return image.get_pixel(p_pos.x, p_pos.y)

func barycentric_coordinates(v_a:Vector3, v_b:Vector3, v_c:Vector3, p:Vector3) -> Vector3:
	
	# Calculate vectors
	var v0 = v_b - v_a
	var v1 = v_c - v_a
	var v2 = p - v_a

	# Calculate dot products
	var dot00 = v0.dot(v0)
	var dot01 = v0.dot(v1)
	var dot11 = v1.dot(v1)
	var dot20 = v2.dot(v0)
	var dot21 = v2.dot(v1)

	# Calculate barycentric coordinates
	var inv_denom = 1.0 / (dot00 * dot11 - dot01 * dot01)
	var v = (dot11 * dot20 - dot01 * dot21) * inv_denom
	var w = (dot00 * dot21 - dot01 * dot20) * inv_denom
	var u = 1.0 - v - w

	return Vector3(u, v, w)

func ray_to_pixel_pos(ray_from:Vector3, ray_dir:Vector3) -> Vector2i:
	
	var mesh:Mesh = $Chunk.mesh
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(mesh, 0)

	var uv:Vector2

	#several triangles might get intersected by the ray, returns the closes one
	var dist_min:float = 1000

	#check each triangle for intersection with the ray
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var normal:Vector3 = mesh_data_tool.get_face_normal(face_index)
		
		#skip backface triangles
		if ray_dir.dot(normal) >= 0:
			continue
		
		var vi_a = mesh_data_tool.get_face_vertex(face_index, 0)
		var vi_b = mesh_data_tool.get_face_vertex(face_index, 1)
		var vi_c = mesh_data_tool.get_face_vertex(face_index, 2)

		var v_a = mesh_data_tool.get_vertex(vi_a)
		var v_b = mesh_data_tool.get_vertex(vi_b)
		var v_c = mesh_data_tool.get_vertex(vi_c)
		
		var pos = Geometry3D.ray_intersects_triangle(ray_from, ray_dir, v_a, v_b, v_c)
		
		#ray intersects triangle
		if pos:

			var dist:float = ray_from.distance_to(pos)
			
			if dist < dist_min:

				dist_min = dist
				
				var uv_a = mesh_data_tool.get_vertex_uv(vi_a)
				var uv_b = mesh_data_tool.get_vertex_uv(vi_b)
				var uv_c = mesh_data_tool.get_vertex_uv(vi_c)

				var bc = barycentric_coordinates(v_a, v_b, v_c, pos)
				
				uv.x = bc.x * uv_a.x + bc.y * uv_b.x + bc.z * uv_c.x
				uv.y = bc.x * uv_a.y + bc.y * uv_b.y + bc.z * uv_c.y
	
	#TODO image size
	return (uv * 256) as Vector2i
