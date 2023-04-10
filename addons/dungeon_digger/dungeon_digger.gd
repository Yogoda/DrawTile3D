@tool
extends EditorPlugin

enum paint_mode {MODE_BLOCKS, MODE_PIXELS}
var mode:paint_mode = paint_mode.MODE_PIXELS

var tile_test:Tile3D = preload("res://addons/dungeon_digger/tiles/tile_test.tres")


func _enter_tree():
	
	set_input_event_forwarding_always_enabled()


func get_cursor_info(mouse_pos, camera, depth=800):
	
	var position
	var normal
	var collider
	
	var node:Node = get_editor_interface().get_edited_scene_root()

	var from:Vector3 = camera.project_ray_origin(mouse_pos)
	var to:Vector3 = from + camera.project_ray_normal(mouse_pos) * depth
	var ray_dir:Vector3 = (to-from).normalized()
	
	var space_state:PhysicsDirectSpaceState3D = node.get_world_3d().direct_space_state
	
	var raycast_param = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(raycast_param)
	
	if result.has("normal"):
		normal = result.normal
	else:
		normal = null

	if result.has("position"):
		position = result.position
	else:
		position = null
		
	if result.has("collider"):
		collider = result.collider
	else:
		collider = null

	return {position=position, normal=normal, collider=collider, ray_from=from, ray_dir=ray_dir}


func _forward_3d_gui_input(camera, event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			var remove_mode:bool = event.shift_pressed
			
			var info = get_cursor_info(event.position, camera)
			
			if info.position != null and info.normal != null:
					
#				var root = get_tree().get_edited_scene_root()
				
				if info.collider is TileMap3D:
#					print("TileMap3D")
					var tile_map:TileMap3D = info.collider
					
					if mode == paint_mode.MODE_PIXELS:
						
						var pixel_pos:Vector2i = tile_map.ray_to_pixel_pos(info.ray_from, info.ray_dir)
						
						print("set pixel:", pixel_pos)
						tile_map.set_pixel(pixel_pos, Color.BLUE)
						
					elif mode == paint_mode.MODE_BLOCKS:
					
						var direction = -1.0
						
						if remove_mode:
							direction = 1.0
						
						var tile_pos = tile_map.coord_to_tile_pos(info.position + direction * info.normal * tile_map.tile_size / 2.0)
						
						if remove_mode:
							tile_map.remove_tile(tile_pos)
							print("remove block:", tile_pos)
						else:
							tile_map.set_tile(tile_pos)
							print("set block:", tile_pos)

						tile_map.generate_mesh(true)
					
#				var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
#
#				if selected_nodes.size() >= 1:
#
#					var selected_node:Node = selected_nodes[0]
#
#					if selected_node is MeshInstance3D:
#
#						var tile_map = selected_node.get_parent()
#						if tile_map is TileMap3D:
							
	#						print("found TileMap3D!")

#							print(info.position, info.normal)

#	return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS


func _input(event):
	return
	print("_asdfinput:", event)
