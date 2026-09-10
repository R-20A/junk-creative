## A joint connecting two [BuildGroup]s.
class_name BuildJoint
extends Object

enum JointType {
	MERGE, # not kinematic as I will add fake forces later
	DYNAMIC # 
}

var type: JointType = JointType.MERGE
var a: BuildGroup
var b: BuildGroup


func is_joint_type(check_type: BuildJoint.JointType):
	return type == check_type
