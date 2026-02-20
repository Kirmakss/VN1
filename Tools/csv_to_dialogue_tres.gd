@tool
extends SceneTree
# CSV (Notion) -> DialogueData.tres generator
#
# Run (Windows example):
# "C:\Path\To\Godot.exe" --headless --path "C:\Path\To\Project" --script res://Tools/csv_to_dialogue_tres.gd -- res://Data/Notion/prologue.csv res://Data/Dialogue/prologue.tres

func _init() -> void:
	# In Godot 4.x, args after `--` are "user args"
	var user_args: PackedStringArray = OS.get_cmdline_user_args()

	# Debug (can be removed later)
	print("CMDLINE:", OS.get_cmdline_args())
	print("USER ARGS:", user_args)

	if user_args.size() < 2:
		printerr("Usage: godot4 --headless --script res://Tools/csv_to_dialogue_tres.gd -- <input.csv> <output.tres>")
		quit(1)
		return

	var input_csv: String = user_args[0]
	var output_tres: String = user_args[1]

	var csv_text := _read_all_text(input_csv)
	if csv_text == "":
		printerr("Failed to read CSV: ", input_csv)
		quit(1)
		return

	var table: Array = _parse_csv(csv_text) # Array[Array[String]]
	if table.size() < 2:
		printerr("CSV is empty or has no data rows: ", input_csv)
		quit(1)
		return

	var headers: Array = table[0]
	var rows: Array = table.slice(1, table.size())

	# Map header -> index
	var idx: Dictionary = {}
	for i in range(headers.size()):
		idx[str(headers[i]).strip_edges()] = i

	var required_cols: Array[String] = [
		"ID", "Speaker", "Text", "Next", "Choices",
		"SetFlags", "ClearFlags", "RequiredFlags", "ForbiddenFlags"
	]
	for col in required_cols:
		if not idx.has(col):
			printerr("Missing column in CSV: ", col)
			quit(1)
			return

	# 1) Read all entries into memory
	var entries_by_id: Dictionary = {} # String -> DialogueEntry
	var ids: Array[String] = []

	for r_any in rows:
		var r: Array = r_any
		if r.size() == 0:
			continue

		var id_ := _cell(r, idx, "ID").strip_edges()
		if id_ == "":
			continue

		if entries_by_id.has(id_):
			printerr("Duplicate ID: ", id_)
			quit(1)
			return

		var e := DialogueEntry.new()
		e.id = id_
		e.speaker = _cell(r, idx, "Speaker").strip_edges()
		e.text = _cell(r, idx, "Text") # keep formatting/newlines
		e.next_id = _cell(r, idx, "Next").strip_edges()

		e.set_flags_on_enter = _parse_flags(_cell(r, idx, "SetFlags"))
		e.clear_flags_on_enter = _parse_flags(_cell(r, idx, "ClearFlags"))

		# You can ignore these in runtime for now, but we store them in Resource for future use
		e.required_flags = _parse_flags(_cell(r, idx, "RequiredFlags"))
		e.forbidden_flags = _parse_flags(_cell(r, idx, "ForbiddenFlags"))

		var choices_raw := _cell(r, idx, "Choices")
		e.choices = _parse_choices(choices_raw)

		entries_by_id[id_] = e
		ids.append(id_)

	# 2) Validate references (next + choices next)
	for id_ in ids:
		var e: DialogueEntry = entries_by_id[id_]

		# Next validation (only if non-empty)
		if e.next_id != "" and not entries_by_id.has(e.next_id):
			printerr("Invalid next_id: ", id_, " -> ", e.next_id)
			quit(1)
			return

		# Choice validation
		for c in e.choices:
			if c.next_id == "":
				printerr("Choice next_id is empty in entry ", id_, " (choice text: ", c.text, ")")
				quit(1)
				return
			if not entries_by_id.has(c.next_id):
				printerr("Invalid choice next_id in entry ", id_, ": ", c.text, " -> ", c.next_id)
				quit(1)
				return

	# 3) Build DialogueData and save
	var data := DialogueData.new()
	data.entries = []

	# Preserve CSV order. If you want sorted: ids.sort()
	for id_ in ids:
		data.entries.append(entries_by_id[id_])

	var err := ResourceSaver.save(data, output_tres)
	if err != OK:
		printerr("Failed to save .tres (code ", err, "): ", output_tres)
		quit(1)
		return

	print("OK: saved ", output_tres, " (entries: ", data.entries.size(), ")")
	quit(0)


# ---------- Helpers ----------

func _read_all_text(path: String) -> String:
	# Supports both res:// and absolute paths
	if path.begins_with("res://"):
		if not FileAccess.file_exists(path):
			return ""
		var f_res := FileAccess.open(path, FileAccess.READ)
		if f_res == null:
			return ""
		return f_res.get_as_text()
	else:
		# absolute / relative to cwd
		if not FileAccess.file_exists(path):
			return ""
		var f_abs := FileAccess.open(path, FileAccess.READ)
		if f_abs == null:
			return ""
		return f_abs.get_as_text()

func _cell(row: Array, idx: Dictionary, name: String) -> String:
	var i: int = int(idx[name])
	if i >= row.size():
		return ""
	return str(row[i])

func _parse_flags(raw: String) -> Array[String]:
	var s := raw.strip_edges()
	if s == "":
		return []

	# Notion CSV обычно даёт "a, b, c"
	# Поддерживаем и вариант с ";" на всякий случай
	var use_semicolon := s.find(";") != -1 and s.find(",") == -1

	var parts: PackedStringArray
	if use_semicolon:
		parts = s.split(";")
	else:
		parts = s.split(",")

	var out: Array[String] = []
	for p in parts:
		var t := str(p).strip_edges()
		if t != "":
			out.append(t)

	return out

func _parse_choices(raw: String) -> Array[DialogueChoice]:
	var out: Array[DialogueChoice] = []
	var text := raw.strip_edges()
	if text == "":
		return out

	for line in text.split("\n"):
		var l := line.strip_edges()
		if l == "":
			continue

		# Notion часто меняет "->" на "→", приводим к стандарту
		l = l.replace("→", "->")

		# Format:
		# <choice text> -> <next_id> [ ? a,b ] [ ! c,d ]
		var arrow_pos := l.find("->")
		if arrow_pos == -1:
			printerr("Bad choice (no ->): ", l)
			continue

		var left := l.substr(0, arrow_pos).strip_edges()
		var right := l.substr(arrow_pos + 2, l.length()).strip_edges()

		# Remove optional surrounding quotes
		if left.begins_with("\"") and left.ends_with("\"") and left.length() >= 2:
			left = left.substr(1, left.length() - 2)

		var next_id := ""
		var req: Array[String] = []
		var forb: Array[String] = []

		var qpos := right.find("?")
		var fpos := right.find("!")

		if qpos == -1 and fpos == -1:
			next_id = right.strip_edges()
		else:
			var end_next := right.length()
			if qpos != -1:
				end_next = min(end_next, qpos)
			if fpos != -1:
				end_next = min(end_next, fpos)

			next_id = right.substr(0, end_next).strip_edges()

			if qpos != -1:
				var qend := right.length()
				if fpos != -1 and fpos > qpos:
					qend = fpos
				var qtext := right.substr(qpos + 1, qend - (qpos + 1)).strip_edges()
				req = _parse_flags(qtext)

			if fpos != -1:
				var ftext := right.substr(fpos + 1, right.length() - (fpos + 1)).strip_edges()
				forb = _parse_flags(ftext)

		var c := DialogueChoice.new()
		c.text = left
		c.next_id = next_id
		c.required_flags = req
		c.forbidden_flags = forb
		out.append(c)

	return out


# CSV parser that supports quoted fields and embedded newlines.
# Returns: Array[Array[String]] where first row is headers.
func _parse_csv(text: String) -> Array:
	var rows: Array = []
	var row: Array[String] = []
	var field := ""
	var in_quotes := false

	var i := 0
	while i < text.length():
		var ch := text[i]

		if in_quotes:
			if ch == "\"":
				# Escaped quote?
				if i + 1 < text.length() and text[i + 1] == "\"":
					field += "\""
					i += 2
					continue
				else:
					in_quotes = false
			else:
				field += ch
		else:
			if ch == "\"":
				in_quotes = true
			elif ch == ",":
				row.append(field)
				field = ""
			elif ch == "\n":
				row.append(field)
				field = ""
				# Drop possible \r in fields
				for j in range(row.size()):
					row[j] = row[j].replace("\r", "")
				rows.append(row)
				row = []
			else:
				field += ch

		i += 1

	# last field / last row
	row.append(field)
	for j in range(row.size()):
		row[j] = row[j].replace("\r", "")
	rows.append(row)

	# remove trailing empty rows
	while rows.size() > 0 and rows[-1].size() == 1 and str(rows[-1][0]).strip_edges() == "":
		rows.pop_back()

	return rows
