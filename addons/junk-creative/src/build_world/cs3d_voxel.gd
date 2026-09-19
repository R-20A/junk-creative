## Physics representation of a voxel, not the actual voxel itself.
class_name VoxelInstance
extends CollisionShape3D

var block_instance: BlockInstance

func _init(parent_block: BlockInstance, global_coordinate: Vector3) -> void:
	self.block_instance = parent_block
	shape = Junk.VOXEL_SHAPE
	
	# set global position inside voxel body
	position = global_coordinate
