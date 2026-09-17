# HOW IT WORKS:
#
# Builds have a simple abstract (calling it meta sucks for some reason...) 
# representation which define what they are and how they are connected
# The player tools interact with this abstract representation!! 
#
# Whenever the build is loaded in, a game/physics/rendering representation will then be loaded too!
# This separates build instances from how they are represented ingame. Very useful for performance reasons or cheating...

## The interface for builds: printing, updating, loading / unloading...
extends Node

#region Game World Notifications
signal group_loaded(group: BuildGroup)
## shortly before it is deleted
signal group_unloaded(group: BuildGroup)

signal joint_loaded(joint: BuildJoint)
signal joint_unloaded(joint: BuildJoint)
#endregion


#region Abstract/meta build groups
# Kinda like the recipe to build physics instances
# All on the same horizontal tree. Every group, every connection.
# Note: Keeping them all here will come in handy, maybe simulating stuff??
var groups: Array[BuildGroup] = []
var joints: Array[BuildJoint] = []
#endregion


#region Update CPU saver stuff
## if groups and joints were added or removed, and stuff needs to be rebuilt in the physical world
var _pending_update := false
var _pending_add_groups: Array[BuildGroup] = []
var _pending_remove_groups: Array[BuildGroup] = []
var _pending_add_joints: Array[BuildJoint] = []
var _pending_remove_joints: Array[BuildJoint] = []
#endregion


func _process(delta: float) -> void:
	# Changes are accumulated in the past frames, then happen all at once??
	if _pending_update and Engine.get_physics_frames() % Junk.PHYSICS_WORLD_UPDATE_TICK_RATE == 0:
		var world := get_tree().root
		
		if Junk.DEBUG:
			print("New groups: %s, Remove groups: %s" % [_pending_add_groups, _pending_remove_groups])
		
		#region Update Groups
		for group in _pending_add_groups:
			groups.push_back(group)
			
			# initialize first time group
			_group_setup_tree(group)
			_group_bake_meshes(group)
			
			_phys_load_group(group, world)
			group_loaded.emit()

		for group in _pending_remove_groups:
			groups.erase(group)
			group_unloaded.emit(group) # call before so cleanup code in other places can run
			_phys_unload_group(group, world)
		#endregion


		#region Update Joints
		for joint in _pending_add_joints:
			joints.push_back(joint)
			_phys_load_joint(joint)
			joint_loaded.emit()

		for joint in _pending_remove_joints:
			joints.erase(joint)
			joint_unloaded.emit(joint) # call before so cleanup code in other places can run
			_phys_unload_joint(joint)
		#endregion
		

		# Clear pending stuff
		_pending_update = false
		_pending_add_groups.clear()
		_pending_remove_groups.clear()
		_pending_add_joints.clear()
		_pending_remove_joints.clear()


#region Meta Building Interface
# ACTUAL BUILDING!! add/remove blocks are all in one place here to manage signals or fx later.

## Creates a group with the first block in [Junk.BLOCK_REGISTRY] already placed.
func build_default_group() -> BuildGroup:
	var default_group := BuildGroup.new()
	var default_block := Junk.BLOCK_REGISTRY.defs[0].make_instance()
	
	group_add_block(default_group, default_block)
	group_load(default_group)
	return default_group


func group_add_block(group: BuildGroup, block: BlockInstance) -> void:
	group.blocks.push_back(block)
	block.owner = group
	
	for voxel_coord in block.res.voxels.voxels:
		group.voxel_body.add_child( VoxelInstance.new(block, voxel_coord) )

	# Update meshes
	_group_bake_meshes.call_deferred(group)


func group_remove_block(group: BuildGroup, block: BlockInstance) -> void:
	group.blocks.erase(block)
	
	# clear all voxels on this group that were owned by the deleted block
	for voxel_instance: VoxelInstance in group.voxel_body.get_children():
		
		if voxel_instance.block_instance == block:
			voxel_instance.queue_free()

	block.free.call_deferred()
	
	# Update meshes
	_group_bake_meshes.call_deferred(group)


## Checks overlaps for all voxels in global space (faster),
## returning an array of bools matching the order of voxel instances
func group_check_overlaps(group: BuildGroup, test_transform: Transform3D = Transform3D.IDENTITY) -> Array[bool]:
	var voxel_nodes := group.voxel_body.get_children()
	
	var overlaps: Array[bool] = []
	overlaps.resize(voxel_nodes.size())
	
	var space_state := group.voxel_body.get_world_3d().direct_space_state
	var query := PhysicsShapeQueryParameters3D.new()
	
	query.exclude = [group.voxel_body]
	query.shape = Junk.VOXEL_SHAPE # same for all voxels
	query.collision_mask = Junk.get_collision_mask(Junk.PHY_LAYER_VOXEL) # Only look for other build voxels for now
	
	# change test transform
	var global_test_transform := group.voxel_body.global_transform
	if test_transform != Transform3D.IDENTITY:
		global_test_transform = test_transform
	
	# And now we check EVERY SINGLE voxel coordinate.
	var voxel_i := 0
	for voxel_instance: VoxelInstance in voxel_nodes:
		query.transform = global_test_transform * voxel_instance.transform
		
		# If there is one result, it overlaps.
		overlaps[voxel_i] = ( space_state.intersect_shape(query, 1) ).size() > 0
		
		# Color debug voxel for debug
		voxel_instance.debug_color = Color.RED if overlaps[voxel_i] else Color(0.0, 0.0, 0.0, 0.0)
		
		# Next...
		voxel_i += 1
	
	return overlaps


## Returns true if any voxel is overlapping
func group_is_overlapping(group: BuildGroup, test_transform: Transform3D = Transform3D.IDENTITY) -> bool:
	var overlaps := group_check_overlaps(group, test_transform)
	for check in overlaps:
		if check == true:
			return true
	
	return false
#endregion



#region Meta-Game Interface
# This interface tells the build master that a group or a joint was created or removed,
# and therefore that it needs to update the physics world!!
#
# But It does not handle creating stuff in the physics world.
# It just tells that a group or joint exists, and it needs to rebuild the game stuff.
#
# I need this extra layer of abstraction to not go crazy with merging rigidbodies or converting them to static.


func group_load(group: BuildGroup) -> void:
	_pending_update = true
	_pending_add_groups.push_back(group)


func group_delete(group: BuildGroup) -> void:
	_pending_update = true
	_pending_remove_groups.push_back(group)


func joint_load(joint: BuildJoint) -> void:
	_pending_update = true
	_pending_add_joints.push_back(joint)


func joint_delete(joint: BuildJoint) -> void:
	_pending_update = true
	_pending_remove_joints.push_back(joint)


## Loads a blueprint in the meta world, skipping entirely on the queue
## and creating physics bodies only when they are not attached to save some bs.
func load_blueprint(blueprint: Blueprint, world: Node3D):
	# these are handled by the blueprint when loading
	var bp_groups: Array[BuildGroup] = []
	var bp_joints: Array[BuildJoint] = []
	
	
	# Optimize loading stuff by only creating the rigidbodies
	# that won't get deleted later due to fake constraints.
	var merge_rules: Array[MergeRule] = []
	var rb_groups: Array[BuildGroup] = bp_groups.duplicate()
	
	
	# 1: Bake groups
	for group in bp_groups:
		_group_bake_meshes(group)
	
	# 2: Figure out what is a rigidbody, and what isn't by looking at the joints
	for joint in bp_joints:
		
		if joint.is_joint_type(BuildJoint.JointType.MERGE):
			rb_groups.erase(joint.group_b) # group_b is not a rigidbody
			merge_rules.push_back( MergeRule.new(joint.group_a, joint.group_b) )
	
	# 3: spawn rbs and attach main collision shape
	for group in rb_groups:
		_phys_load_group(group, world)

		
	# 4: merge groups together using rules
	for rule in merge_rules:
		_joint_create_merge(rule.group_a, rule.group_b)
		rule.free()
	
	# Add newly added stuff to groups
	groups.append_array(bp_groups)
	joints.append_array(bp_joints)
	
	# clear groups
	bp_groups.clear()
	bp_joints.clear()
	merge_rules.clear()
	rb_groups.clear()
#endregion


#region Game world interface for groups and joints
# This is done in the physics representation, and therefore is private to the build master.
# Other classes only control adding and removing blocks


## Sets up the node tree for the group
func _group_setup_tree(group: BuildGroup) -> void:
	group.phys_group_shape.shape = group.baked_phys_shape
	group.mesh_instance.mesh = group.baked_mesh
	
	group.phys_group_shape.add_child(group.voxel_body)
	group.phys_group_shape.add_child(group.mesh_instance)
	
	#region Layers
	group.voxel_body.collision_layer = 0
	group.voxel_body.set_collision_layer_value(Junk.PHY_LAYER_VOXEL, true)
	#endregion


## Bakes the block group into physics and mesh
func _group_bake_meshes(group: BuildGroup):
	
	#region Merge Render and Physics meshes
	# clear mesh data
	group.baked_mesh.clear_surfaces()
	
	# surface tool to merge render meshes
	var st := SurfaceTool.new()
	
	# array to hold phys shape stuff
	var phys_triangles := PackedVector3Array()
	
	
	# loop over all blocks and accumulate meshes
	for block: BlockInstance in group.blocks:
		
		# local transform relative to group origin
		var local_transform := Transform3D(Basis.IDENTITY, block.position)
		
		var render_mesh := block.res.mesh_render
		# huge time saver from Godot here (append existing mesh)
		st.append_from(render_mesh, 0, local_transform)
		
		
		# Append physics triangles
		phys_triangles.append_array(block.res.mesh_physics.get_faces())
		
	
	# update resources
	group.baked_mesh = st.commit(group.baked_mesh)
	group.baked_phys_shape.set_faces(phys_triangles)
	#endregion


## Loads a group as a physics body
func _phys_load_group(group: BuildGroup, world: Node) -> void:
	_group_under_physics_body(group, world)


## Unloads a group from the physics world, and any joints connected to it
func _phys_unload_group(group: BuildGroup, world: Node) -> void:
	# find any physics joint that was using this group
	for joint in joints:
		
		# destroy physics joint
		if joint.group_a == group or joint.group_b == group:
			_phys_unload_joint(joint)

	# destroy physics of this group
	_group_lose_own_physics(group)


## Loads a joint in the physics world
func _phys_load_joint(joint: BuildJoint) -> void:
	match joint.type:
		BuildJoint.JointType.MERGE:
			# Add A to B
			_joint_create_merge(joint.group_a, joint.group_b)
		BuildJoint.JointType.DYNAMIC:
			# create physics joint
			pass


## Unloads a joint from the physics world
func _phys_unload_joint(joint: BuildJoint) -> void:
	match joint.type:
		BuildJoint.JointType.MERGE:
			# remove B from A, and turn B into a rigidbody
			_joint_delete_merge(joint.a, joint.b)
		BuildJoint.JointType.DYNAMIC:
			# Simply delete standard joint
			joint.phys_joint.queue_free()
#endregion


#region Group Utility
func _group_under_physics_body(group: BuildGroup, phys_world: Node) -> void:
	group.phys_body = RigidBody3D.new()
	
	group.phys_body.collision_layer = 0
	group.phys_body.set_collision_layer_value(Junk.PHY_LAYER_BUILD, true)
	
	group.phys_body.freeze = group.freeze
	
	group.phys_body.add_child(group.phys_group_shape)
	phys_world.add_child(group.phys_body)


func _group_lose_own_physics(group: BuildGroup) -> void:
	if group.phys_body:
		group.phys_body.remove_child(group.phys_group_shape)
		group.phys_body.queue_free()
#endregion


#region Merge Joints Utility
func _joint_create_merge(main_group: BuildGroup, merge_group: BuildGroup):
	_group_lose_own_physics(merge_group)
	main_group.phys_body.add_child(merge_group.phys_group_shape)


func _joint_delete_merge(main_group: BuildGroup, merge_group: BuildGroup):
	main_group.phys_body.remove_child(merge_group.phys_group_shape)
	_group_under_physics_body(merge_group, main_group.phys_body.get_parent_node_3d())
#endregion


## Joint Merge Rule for loading quickly blueprints
class MergeRule extends RefCounted:
	## main
	var group_a: BuildGroup
	## merge
	var group_b: BuildGroup
	
	func _init(group_a: BuildGroup, group_b: BuildGroup) -> void:
		self.group_a = group_a
		self.group_b = group_b
