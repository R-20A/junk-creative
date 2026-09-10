## A collection of blocks welded together
class_name BuildGroup
extends Object

## If this is the root group of a build
## then (attempt to) remember other spawned groups here when the player goes back to the bench
## TODO: do this with IDs instead of group references...
var blueprint_mates: Array[BuildGroup]

#region Baked Entities
var baked_com: Vector3
var baked_shape: ConcavePolygonShape3D
var baked_mesh: Mesh
#endregion


#region Physics Entities
## The physics body this group is simulated under
var physics_body: RigidBody3D
var shape_instance: CollisionShape3D = CollisionShape3D.new()
#endregion
