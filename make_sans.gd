extends Label


func _init():
	var system_font := SystemFont.new()
	system_font.font_names = [
		"Comic Sans MS",
		"ComicSansMS",
		"Comic Sans",
		"ComicSans",
		"Comic Sans MS Regular",
		"Comic Sans MS Bold",
		"Comic Sans MS Italic",
		"Comic Sans MS Bold Italic"
	]
	add_theme_font_override("Comic Sans", system_font )
