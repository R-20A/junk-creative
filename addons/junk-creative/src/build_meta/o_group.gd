## A collection of blocks welded together
class_name BuildGroup
extends Object


#region Transform Identity
## local, global?? must be fetched from physics
var transform := Transform3D()

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
var baked_shape: ConcavePolygonShape3D
var baked_mesh: Mesh
#endregion


#region Physics Entities
## The [CollisionShape3D] for terrain / vehicle to vehicle collisions (no vehicles inside vehicles until I figure out Bricadia-like CD) [br]
## Also acts as the root of this block in the game tree... ?
var phys_group_shape: CollisionShape3D = CollisionShape3D.new()

## The physics body this [BuildGroup] is simulated under
var phys_body: RigidBody3D

## The static body for this group used to raycast voxels for building, interaction, and maybe projectiles??
var voxel_body: StaticBody3D
#endregion


## If this is the root group of a build
## then (attempt to) remember other spawned groups here when the player goes back to the bench
## TODO: do this with IDs instead of group references...
var blueprint_mates: Array[BuildGroup]
