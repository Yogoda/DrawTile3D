@tool
extends PanelContainer

enum DRAW_MODE {PIXEL, TILE2D, TILE3D}
var draw_mode = DRAW_MODE.TILE3D

var selected_color:Color = Color.CORNFLOWER_BLUE

func _ready():
	
	build_tile_2d_list()
	
func build_tile_2d_list():
	
	var tile_list:ItemList = %Tile2DList
	tile_list.clear()
	
	var image:ImageTexture = preload("res://atlas.image_texture.res")
	
	var icon:Texture2D = image
	
	for x in range(16):
		
		for y in range(16):
			
			var index = tile_list.add_item("", icon)
			
			tile_list.set_item_icon_region(index, Rect2(x*16, y*16, 16, 16))


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
