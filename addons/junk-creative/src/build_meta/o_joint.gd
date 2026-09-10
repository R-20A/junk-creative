## A joint connecting two [BuildGroup]s.
class_name BuildJoint
extends Object

enum JointType {
	MERGE, # not kinematic as I will add fake forces later
	DYNAMIC # 
}

var type: JointType = JointType.MERGE
var group_a: BuildGroup
var group_b: BuildGroup

var phys_joint: Joint3D


func is_joint_type(check_type: BuildJoint.JointType):
	return type == check_type


func is_merge_joint() -> bool:
	return type == JointType.MERGE
