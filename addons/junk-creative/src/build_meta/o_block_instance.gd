## The placed block holding variables and a reference to the original [BlockResource]
class_name BlockInstance
extends Object


## Resource of original block
var res: BlockDefinition


## The [BuildGroup] that owns this
var owner: BuildGroup


#region Voxel Space Block Transform
## Voxel position of this block, relative to [BuildGroup] origin
var position: Vector3i

## 90 degree orientation of this block
#var rotation:
#endregion
