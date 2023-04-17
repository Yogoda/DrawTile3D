@tool
extends PanelContainer

var selected_color:Color = Color.CORNFLOWER_BLUE

func set_selected_color(p_color:Color):
	
	selected_color = p_color
	%SelectedColor.color = selected_color

func _on_draw_color_color_changed(p_color):
	selected_color = p_color
