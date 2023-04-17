@tool
extends PanelContainer

enum DRAW_MODE {PIXEL, TILE2D, TILE3D}
var draw_mode = DRAW_MODE.TILE3D

var selected_color:Color = Color.CORNFLOWER_BLUE

func set_selected_color(p_color:Color):
	
	selected_color = p_color
	%SelectedColor.color = selected_color

func _on_draw_color_color_changed(p_color):
	selected_color = p_color

func _on_btn_mode_tile_3d_pressed():
	draw_mode = DRAW_MODE.TILE3D

func _on_btn_mode_tile_2d_pressed():
	draw_mode = DRAW_MODE.TILE2D

func _on_btn_mode_pixel_pressed():
	draw_mode = DRAW_MODE.PIXEL
