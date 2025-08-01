extends RichTextLabel

@export var target_group:=&"Player"
@export var prop_list:Array[StringName] = [
	&"name"
]

@export var method_list:Array[StringName] = [
	
]

func _process(_delta: float) -> void:
	text = ""
	for target in get_tree().get_nodes_in_group(target_group):
		for p in prop_list:
			if p == &"": continue
			text += "{}: {}\n".format([p, target.get(p)], "{}")
		
		for m in method_list:
			if m == &"": continue
			text += "{}: {}\n".format([m, target.call(m)], "{}")
