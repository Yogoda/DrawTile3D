@tool
extends EditorPlugin


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _enter_tree():
	
	set_input_event_forwarding_always_enabled()

func get_cursor_info(mouse_pos, camera, depth=800):
	
	var position
	var normal
	
	var node = get_editor_interface().get_edited_scene_root()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * depth
	
	var space_state = node.get_world_3d().direct_space_state
	
	var raycast_param = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(raycast_param)
	
	if result.has("normal"):
		normal = result.normal
#		print("normal:", result.normal)
	else:
		normal = null

	if result.has("position"):
		position = result.position
#		print("normal:", result.normal)
	else:
		position = null

	return {position=position, normal=normal}

func _forward_3d_gui_input(camera, event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			var info = get_cursor_info(event.position, camera)
			
			if info.position != null and info.normal != null:
					
				var root = get_tree().get_edited_scene_root()
				
				var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()

				if selected_nodes.size() >= 1:

					var selected_node:Node = selected_nodes[0]
					
					if selected_node is MeshInstance3D:
						
						var tile_map = selected_node.get_parent()
						if tile_map is TileMap3D:
							
	#						print("TileMap3D!")

							print(info.position, info.normal)
							
							var selected_tile:Vector3 = info.position - info.normal * tile_map.tile_size / 2.0
							
							selected_tile = (selected_tile + tile_map.tile_size / 2.0) / tile_map.tile_size
	#						print("selected tile:", selected_tile)
							selected_tile = selected_tile.floor()
							print("selected tile:", selected_tile)
							
							tile_map.set_tile(selected_tile as Vector3i)
							tile_map.generate_mesh(true)
				

#	return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _input(event):
	return
	print("_asdfinput:", event)
