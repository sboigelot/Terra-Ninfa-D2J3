@tool
extends EditorPlugin

var csgbox_inspector_plugin:EditorInspectorPlugin
var water_node_3d_inspector_plugin:EditorInspectorPlugin

func _enter_tree():
	csgbox_inspector_plugin = preload("csgbox_inspector_plugin.gd").new()
	add_inspector_plugin(csgbox_inspector_plugin)
	water_node_3d_inspector_plugin = preload("water_node_3d_inspector_plugin.gd").new()
	add_inspector_plugin(water_node_3d_inspector_plugin)

func _exit_tree():
	if csgbox_inspector_plugin:
		remove_inspector_plugin(water_node_3d_inspector_plugin)
