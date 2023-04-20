@tool
extends EditorPlugin

var dd_panel

#func _enter_tree():

#	_enable_plugin()
#
#	dd_panel = preload("res://addons/dungeon_digger/dd_panel.tscn").instantiate()
#	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dd_panel)
##	add_control_to_bottom_panel(dd_panel, "DungeonDigger")
#	set_input_event_forwarding_always_enabled()
#
#func _exit_tree():
#
#	remove_control_from_docks(dd_panel)
##	remove_control_from_bottom_panel(dd_panel)
#	dd_panel.queue_free()
	
func _enable_plugin():
	
	dd_panel = preload("res://addons/dungeon_digger/dungeon_digger_panel.tscn").instantiate()
	get_tree().set_meta("__dungeon_digger_panel", dd_panel)
#	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dd_panel)
	add_control_to_bottom_panel(dd_panel, "DungeonDigger")
	set_input_event_forwarding_always_enabled()
	
func _disable_plugin():
	
#	remove_control_from_docks(dd_panel)
	remove_control_from_bottom_panel(dd_panel)
#	dd_panel.queue_free()

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

func tilemap_action(cursor_info, remove_mode:bool, copy_mode:bool):
	
	if cursor_info.position != null and cursor_info.normal != null:
			
#				var root = get_tree().get_edited_scene_root()
		
		if cursor_info.collider is TileMap3D:

			var tile_map:TileMap3D = cursor_info.collider
			
			if dd_panel.draw_mode == dd_panel.DRAW_MODE.PIXEL:
				
				var pixel_pos:Vector2i = tile_map.ray_to_pixel_pos(cursor_info.ray_from, cursor_info.ray_dir)
				
				print("set pixel:", pixel_pos)
				
				if copy_mode:
					var color = tile_map.get_pixel(pixel_pos)
					dd_panel.set_selected_color(color)
				else:
					tile_map.set_pixel(pixel_pos, dd_panel.selected_color)
					
			elif dd_panel.draw_mode == dd_panel.DRAW_MODE.TILE2D:
				
				var tile_pos = tile_map.coord_to_tile_pos(cursor_info.position + cursor_info.normal * tile_map.tile_size / 2.0)
				
				var face:Vector3i = Vector3i.ZERO
				
				if cursor_info.normal.dot(Vector3.LEFT) > 0.5:
					face = Vector3i.RIGHT
				elif cursor_info.normal.dot(Vector3.RIGHT) > 0.5:
					face = Vector3i.LEFT
				elif cursor_info.normal.dot(Vector3.DOWN) > 0.5:
					face = Vector3i.UP
				elif cursor_info.normal.dot(Vector3.UP) > 0.5:
					face = Vector3i.DOWN
				elif cursor_info.normal.dot(Vector3.FORWARD) > 0.5:
					face = Vector3i.BACK
				elif cursor_info.normal.dot(Vector3.BACK) > 0.5:
					face = Vector3i.FORWARD
				
				tile_map.set_tile_2D(tile_pos, face)
				
				tile_map.generate_mesh(true)
				
			elif dd_panel.draw_mode == dd_panel.DRAW_MODE.TILE3D:
			
				var direction = -1.0
				
				if remove_mode:
					direction = 1.0
				
				var tile_pos = tile_map.coord_to_tile_pos(cursor_info.position + direction * cursor_info.normal * tile_map.tile_size / 2.0)
				
				if remove_mode:
					tile_map.remove_tile_3D(tile_pos)
					print("remove tile 3D:", tile_pos)
				else:
					tile_map.set_tile_3D(tile_pos, dd_panel.selected_tile_2D)
					print("set tile 3D:", tile_pos)

				tile_map.generate_mesh(true)

func _forward_3d_gui_input(camera, event):
	
#	print(event)
	
	if event is InputEventMouseMotion and dd_panel.draw_mode != dd_panel.DRAW_MODE.TILE3D:
		
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			
			var cursor_info = get_cursor_info(event.position, camera)
			
			tilemap_action(cursor_info, event.shift_pressed, event.ctrl_pressed)
	
	elif event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			var cursor_info = get_cursor_info(event.position, camera)
			
			tilemap_action(cursor_info, event.shift_pressed, event.ctrl_pressed)
			
#	return EditorPlugin.AFTER_GUI_INPUT_STOP
#	return EditorPlugin.AFTER_GUI_INPUT_PASS
	return EditorPlugin.AFTER_GUI_INPUT_CUSTOM


func _input(event):
	return
