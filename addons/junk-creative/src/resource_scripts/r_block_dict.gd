## Matches [int] ID slots with a particular [BlockDefinition] resource
class_name BlockRegistry
extends Resource


## Block definitions for this dictionary. [br]
## Remember to not swap slots with eachother, or builds will load all messed up...
@export var defs: Dictionary[int, BlockDefinition] = {}
