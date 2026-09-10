## The interface for builds: printing, updating, loading / unloading...
extends Node

signal group_loaded
signal group_unloaded

signal joint_loaded
signal joint_unloaded


class MergeRule extends RefCounted:
	## main
	var a: BuildGroup
	## merge
	var b: BuildGroup
	
	func _init(a: BuildGroup, b: BuildGroup) -> void:
		self.a = a
		self.b = b


#region Meta Build Groups
# Kinda like the recipe to build physics instances
var groups: Array[BuildGroup] = []
var joints: Array[BuildJoint] = []
#endregion


func load_blueprint(blueprint: Blueprint, world: Node3D):
	# these are handled by the blueprint when loading
	var bp_groups: Array[BuildGroup] = []
	var bp_joints: Array[BuildJoint] = []
	
	var merge_rules: Array[MergeRule] = []
	var rb_groups: Array[BuildGroup] = bp_groups.duplicate()
	
	# 1: Bake groups
	for group in bp_groups:
		bake_group(group)
	
	# 2: Figure out what is a rigidbody, and what isn't by looking at the joints
	for joint in bp_joints:
		
		if joint.is_joint_type(BuildJoint.JointType.MERGE):
			rb_groups.erase(joint.b) # b is not a rigidbody
			merge_rules.push_back( MergeRule.new(joint.a, joint.b) )
	
	# 3: spawn rbs and attach main collision shape
	for group in rb_groups:
		group.physics_body = RigidBody3D.new()
		group.physics_body.add_child(group.shape_instance)
		world.add_child(group.physics_body)
		
	# 4: merge groups together using rules
	for rule in merge_rules:
		rule.a.physics_body.add_child(rule.b.shape_instance)
	
	# creation is loaded!! Lmao, conceptually.



func bake_group(group: BuildGroup):
	pass
