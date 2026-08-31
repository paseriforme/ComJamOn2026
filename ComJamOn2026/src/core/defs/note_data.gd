extends Resource
class_name NoteData

## Dato inmutable de una nota. Es lo único que persiste en la Song.

enum Type { TAP, HOLD, OPEN }

@export var time: float = 0.0
@export var chord: Array[bool] = []
@export var duration: float = 0.0
@export var type: Type = Type.TAP
