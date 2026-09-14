## Constants and static functions for the [JunkCreative] plugin
## I should later move these to project settings??
class_name Junk


#region Resources
## The physics shape for voxels to use for raycasting, needed to place or check overlaps
const VOXEL_SHAPE := preload("uid://kv155cll1tht")


## The registry storing all references to [BlockDefinitions]
## Will move it to a project setting once I get things going.
const BLOCK_REGISTRY := preload("uid://c0h4d443uukg8")
#endregion


#region Physics Layers
const PHY_LAYER_ENVIRONMENT := 1
#const PHY_LAYER_SWIMMABLE := 2 # Do I need this at all??

const PHY_LAYER_BUILD := 10
const PHY_LAYER_VOXEL := 11

const PHY_LAYER_CHAR_CONTROLLER := 20
const PHY_LAYER_CHAR_BONES := 21 # Hitboxes and ragdoll


static func get_collision_mask(layer: int) -> int:
	return 1 << (layer - 1)
#endregion


#region ...
## Tick rate for updating physics world. 
## A greater rate will accumulate more operations creating input delay, and introduce stuttering as more shit at once needs to be handled
## Why the fuck have I added this??? Lmfao
## I need some sort of stagger or async stuff to make this work decently, still it's a good basis for now.
const PHYSICS_WORLD_UPDATE_RATE := 30
#endregion


#region Editor
## The length of the raycast for mouse picking.
## Lower it to avoid accidentally building on stuff so far away the player can't even see.
const EDITOR_RAYCAST_LENGTH := 10.0
#endregion
