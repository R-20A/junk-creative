class_name VoxelInstance
extends CollisionShape3D

var block_instance: BlockInstance

func _init(parent_block: BlockInstance, coordinate: Vector3i) -> void:
	self.block_instance = parent_block
	shape = Junk.VOXEL_SHAPE
	position = Vector3(coordinate)
