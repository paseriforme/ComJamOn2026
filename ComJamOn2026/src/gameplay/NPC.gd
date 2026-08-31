@tool
extends RigidBody2D
class_name NPC

enum NPC_type {COLEGA, MUCHACHA, TRONCA, CHAVALA, MANAGER}

@export_group("Visual")
@export var TEXTURE 		:= preload("uid://dk6ux8aiesioe")
@export var selfNPC 		: NPC_type = NPC_type.MANAGER
@export var dialogue		: int = 0
@export var distance_factor : float = 0.05
@export var tween_time 		: float = 0.5

@export_group("Referencias")
@export var sprite_2d		: Sprite2D
@export var audio_player	: AudioStreamPlayer2D

@export_group("Juego")
@export var song : Song:
	set(value):
		song = value
		# Si la dificultad guardada ya no existe en la nueva canción, la reseteamos
		if song == null or not song.difficulties.has(difficulty):
			difficulty = _first_difficulty()
		notify_property_list_changed() # Redibuja el inspector

# Backing field: se exporta dinámicamente en _get_property_list, no con @export
var difficulty : String = ""

var _sprite_ini_pos: Vector2

# --- GENERACIÓN DINÁMICA DEL MENÚ ---
func _get_property_list() -> Array[Dictionary]:
	#print("get_property_list llamado | song=", song, " | difficulties=", song.difficulties if song else "N/A")
	var hint_string := "Vacio"
	if song != null and song.difficulties.size() > 0:
		hint_string = ",".join(PackedStringArray(song.difficulties.keys()))

	return [{
		"name": "difficulty",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_DEFAULT,  # EDITOR + STORAGE (se muestra y se guarda)
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string
	}]


func _set(property: StringName, value: Variant) -> bool:
	if property == "difficulty":
		difficulty = value
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == "difficulty":
		return difficulty
	return null


# Permite el botón de "revertir" (la flechita) junto al campo
func _property_can_revert(property: StringName) -> bool:
	return property == "difficulty"


func _property_get_revert(property: StringName) -> Variant:
	if property == "difficulty":
		return _first_difficulty()
	return null


func _first_difficulty() -> String:
	if song != null and song.difficulties.size() > 0:
		return song.difficulties.keys()[0]
	return ""

func _ready() -> void:
	# Evita que el código se ejecute en el editor
	if Engine.is_editor_hint(): return
	_sprite_ini_pos = sprite_2d.position
	sprite_2d.texture = TEXTURE

func _on_body_entered(body: Node) -> void:
	# Evita que el código se ejecute en el editor
	if Engine.is_editor_hint(): return
	
	# Solo salta el dialogo si es un choque con el jugador
	if body is not WorldPlayerController: return
	
	var dir: Vector2 = Global.direccion_jugador
	var trans : Tween.TransitionType = Tween.TRANS_SINE
	var tween2: Tween = get_tree().create_tween()
	SoundSystem.play_sfx("bounce", 0.2)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.tween_property(sprite_2d, "position", _sprite_ini_pos + dir * distance_factor, tween_time/2).set_trans(trans)
	tween2.set_ease(Tween.EASE_IN)
	tween2.tween_property(sprite_2d, "position", _sprite_ini_pos, tween_time/2).set_trans(trans)
	Global.npc_hit.emit(self)
