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

@export var reset:bool = false

@export_category("Params")

@export var tile_size:Vector3 = Vector3(1.0, 1.0, 1.0)
@export var tiles_xcount:=16

var tile_shape_cube:TileShape = preload("res://addons/dungeon_digger/tile_shapes/block/cube.tile_shape.tres")
var tile_shape_cube_flipped:TileShape = preload("res://addons/dungeon_digger/tile_shapes/block/cube_flipped.tile_shape.tres")

var dd_panel:DungeonDiggerPanel

#var selected_tile_index:int
#var selected_tile_3D:Tile3D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_meta("_edit_lock_", true)
	set_meta("_edit_group_", true)


func get_selected_tile_index():
	
	if dd_panel == null:
		dd_panel = get_tree().get_meta("__dungeon_digger_panel")
		
	return dd_panel.selected_tile_index


func create_test_tiles():
	
	var mesh:Mesh = load("res://starting_mesh.mesh.res")
	$Chunk.mesh = mesh.duplicate()
	
	update_collision()


func coord_to_block_pos(p_coord:Vector3) -> Vector3i:
	
	var tile_pos = p_coord
	
	tile_pos = (tile_pos + tile_size / 2.0) / tile_size
	tile_pos = tile_pos.floor()

	return tile_pos as Vector3i


func dig_block(p_pos:Vector3i, p_tile_index:int):
	
	update_mesh(p_pos, p_tile_index, true)


func place_block(p_pos:Vector3i, p_tile_index:int):
	
	update_mesh(p_pos, p_tile_index, false)


func set_tile_index(p_block_pos:Vector3i, p_face:Vector3i, p_tile_index):
	
	update_mesh_tile(p_block_pos, p_face as Vector3, p_tile_index)


func get_vertex_uv(p_vertex:Vector3, p_normal:Vector3, p_tile_index:int) -> Vector2:
	
	var uv:Vector2 = Vector2.ZERO

		#set uv according to triangle direction
	if p_normal.dot(Vector3.FORWARD) > 0.5:
		uv.x = p_vertex.x
		uv.y = -p_vertex.y
	elif p_normal.dot(Vector3.BACK) > 0.5:
		uv.x = -p_vertex.x
		uv.y = -p_vertex.y
	elif p_normal.dot(Vector3.LEFT) > 0.5:
		uv.x = -p_vertex.z
		uv.y = -p_vertex.y
	elif p_normal.dot(Vector3.RIGHT) > 0.5:
		uv.x = p_vertex.z
		uv.y = -p_vertex.y
	else:
		uv.x = p_vertex.x
		uv.y = p_vertex.z
		
	var tile_size_ = 2.0
	uv.x = (uv.x + tile_size_ / 2.0) / tile_size_
	uv.y = (uv.y + tile_size_ / 2.0) / tile_size_
	
	var tile_2D_x = p_tile_index % tiles_xcount
	var tile_2D_y = floor(p_tile_index / tiles_xcount)
	
	#tile coordinate
	uv.x = uv.x / tiles_xcount + tile_2D_y * (1.0 / tiles_xcount)
	uv.y = uv.y / tiles_xcount + tile_2D_x * (1.0 / tiles_xcount)

	return uv

func add_mesh_to_surface(p_mesh_to_copy:Mesh, 
						p_surface_tool:SurfaceTool, 
						p_tile_pos:Vector3i, 
						p_tile_index:int):
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(p_mesh_to_copy, 0)

	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var face_normal = mesh_data_tool.get_face_normal(face_index)
		
		for vi in range(3):
			
			var vertex_index = mesh_data_tool.get_face_vertex(face_index, vi)
			
			vertex = mesh_data_tool.get_vertex(vertex_index)
			normal = mesh_data_tool.get_vertex_normal(vertex_index)
			
			uv = get_vertex_uv(vertex, face_normal, p_tile_index)

			vertex *= tile_size / 2.0
			vertex += (p_tile_pos as Vector3) * tile_size
			
			p_surface_tool.set_uv(uv)
			p_surface_tool.set_normal(normal)
			p_surface_tool.add_vertex(vertex)


func get_block_bounds(p_pos:Vector3i) -> Bounds:
	
	var margin = 0.01
	
	var min:Vector3 = Vector3.ZERO - tile_size / 2.0
	var max:Vector3 = Vector3.ZERO + tile_size / 2.0
	
	min -= tile_size * margin
	max += tile_size * margin
	
	min += tile_size * (p_pos as Vector3)
	max += tile_size * (p_pos as Vector3)
	
	return Bounds.new(min, max)


func create_block_face(p_surface_tool:SurfaceTool, p_block_pos:Vector3i, p_face:Vector3i, p_tile_index:int, p_dig:bool):
	
	var tile_shape:TileShape
	
	if p_dig:
		tile_shape = tile_shape_cube_flipped
	else:
		tile_shape = tile_shape_cube

	if p_dig:
		
		if p_face == Vector3i.LEFT:
			add_mesh_to_surface(tile_shape.mesh_right, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.RIGHT:
			add_mesh_to_surface(tile_shape.mesh_left, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.UP:
			add_mesh_to_surface(tile_shape.mesh_up, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.DOWN:
			add_mesh_to_surface(tile_shape.mesh_down, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.BACK:
			add_mesh_to_surface(tile_shape.mesh_forward, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.FORWARD:
			add_mesh_to_surface(tile_shape.mesh_back, p_surface_tool, p_block_pos, p_tile_index)
			
	else:
		
		if p_face == Vector3i.LEFT:
			add_mesh_to_surface(tile_shape.mesh_left, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.RIGHT:
			add_mesh_to_surface(tile_shape.mesh_right, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.UP:
			add_mesh_to_surface(tile_shape.mesh_down, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.DOWN:
			add_mesh_to_surface(tile_shape.mesh_up, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.BACK:
			add_mesh_to_surface(tile_shape.mesh_back, p_surface_tool, p_block_pos, p_tile_index)
		if p_face == Vector3i.FORWARD:
			add_mesh_to_surface(tile_shape.mesh_forward, p_surface_tool, p_block_pos, p_tile_index)


func update_mesh(p_block_pos:Vector3i, p_tile_index:int, p_dig = true):
	
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
	
	#create missing faces
	for face in block_faces:
		create_block_face(surface_tool, p_block_pos, face, p_tile_index, p_dig)

	#set mesh
	var mesh:Mesh = surface_tool.commit()
	$Chunk.mesh = mesh
	
#	update_collision()


func update_mesh_tile(p_block_pos:Vector3i, p_normal:Vector3, p_tile_index:int):
	
	var mesh_data_tool:MeshDataTool = MeshDataTool.new()
	mesh_data_tool.create_from_surface($Chunk.mesh, 0)
	
	var vertex:Vector3
	var normal:Vector3
	var uv:Vector2
	
	#the bounds of the updated block to search faces
	var block_bounds = get_block_bounds(p_block_pos)
	
	#TRIANGLES
	for face_index in range(mesh_data_tool.get_face_count()):
		
		var face_normal = mesh_data_tool.get_face_normal(face_index)
		
		if face_normal.dot(p_normal) > 0.5:
		
			var face_in_bounds:bool = true
			
			#is the face in update bounds ?
			for vi in range(3):
				
				var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)
				
				vertex = mesh_data_tool.get_vertex(vertex_index)
				
				if not block_bounds.is_in_bounds(vertex):
					face_in_bounds = false
					break
				
			if face_in_bounds:
				
				for vi in range(3):
					
					var vertex_index = mesh_data_tool.get_face_vertex(face_index,vi)

					vertex = mesh_data_tool.get_vertex(vertex_index)
					
					vertex -= (p_block_pos as Vector3) * tile_size
					vertex /= tile_size / 2.0
					
					uv = get_vertex_uv(vertex, face_normal, p_tile_index)
					
					mesh_data_tool.set_vertex_uv(vertex_index, uv)

	$Chunk.mesh.clear_surfaces()
	mesh_data_tool.commit_to_surface($Chunk.mesh)

func update_collision():
	
	#set collision
	var faces:Array = $Chunk.mesh.surface_get_arrays(0)[0]
	$CollisionShape3D.shape.set_faces(faces)


func set_pixel(p_pos:Vector2i, color:Color):
	
	var material:StandardMaterial3D = $Chunk.material_override
	var texture:Texture2D = material.albedo_texture
	#get a copy of the image
	var image:Image = texture.get_image()

	image.set_pixel(p_pos.x, p_pos.y, color)

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
