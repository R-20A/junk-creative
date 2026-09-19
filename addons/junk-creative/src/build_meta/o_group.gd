## A collection of blocks welded together. [br]
## 
## Once loaded by the [BuildMaster], a [BuildGroup] is always represented by 3 different nodes:
## - The physics collision shape, root of all other nodes
## - The rendering mesh, childed to the collision shape
## - The voxel body, again childed to the physics shape and used for building
## The [BuildMaster] handles all 3.
class_name BuildGroup
extends Object


#region Transform Identity
## the physics transform of this group, or the relative transform when merged??
var transform := Transform3D():
	get:
		if phys_body:
			return phys_body.global_transform
		return transform
	
	set(value):
		if phys_body:
			phys_body.set_deferred("global_transform", value)
		else:
			transform = value


var position:
	get:
		return transform.origin
	set(value):
		transform.origin = value

var rotation:
	get:
		return transform.basis.get_euler()
#endregion


#region Data
var blocks: Array[BlockInstance] = []
#endregion



#region Baked Entities
var baked_com: Vector3
var baked_phys_shape := ConcavePolygonShape3D.new()
var baked_mesh := ArrayMesh.new()
#endregion


#region Instance Entities
## The physics body this [BuildGroup] is simulated under
var phys_body: RigidBody3D # changes depending on joints

## The [CollisionShape3D] for terrain / vehicle to vehicle collisions (no vehicles inside vehicles until I figure out Bricadia-like CD) [br]
## Also acts as the root of this block in the game tree... ?
var phys_group_shape := CollisionShape3D.new()

## The static body for this group used to raycast voxels for building, interaction, and maybe projectiles??
var voxel_body := StaticBody3D.new()

## The instance that holds the baked render mesh
var mesh_instance := MeshInstance3D.new()
#endregion


#region Editor
## Debug rn
var freeze := true

## If this is the root group of a build
## then (attempt to) remember other spawned groups here when the player goes back to the bench
## TODO: do this with IDs instead of group references...
var blueprint_mates: Array[BuildGroup]
#endregion


## Creates a new copy of this group
func make_copy() -> BuildGroup:
	var copy := BuildGroup.new()
	copy.transform = transform
	
	for block in blocks:
		var copy_block := block.res.make_instance()
		copy_block.position = block.position
		
		## Does extra stuff than pushing back to array
		BuildMaster.group_add_block(copy, copy_block)
	
	return copy
