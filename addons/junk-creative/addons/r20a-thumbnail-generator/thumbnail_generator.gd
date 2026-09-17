@tool

class_name ThumbnailGenerator extends Node

## Dict: viewport_container, viewport, camera3D
var _studio: Dictionary

const BG_COLOR = Color.WHITE


## Same as [ThumbnailGenerator.generate_thumbnail], but uses a packed scene instead (root must be a Node3D!!).
static func generate_thumbnail_packed(packed_scene: PackedScene, size: int = 128) -> ImageTexture:
	# Instantiate packed scene
	var thumbnail_scene: Node3D = packed_scene.instantiate()
	if thumbnail_scene is not Node3D:
		push_error("Thumbnail scene has no 3D objects!! " + packed_scene.resource_path)
		return null

	return generate_thumbnail(thumbnail_scene, size)


## Generates a thumbnail using the [RenderingServer]
static func generate_thumbnail(thumbnail_scene: Node3D, size: int = 128) -> ImageTexture:
	

	
	#print("Generating thumbnail for: " + packed_scene.resource_path)
	
	# BUILDING SCENARIO
	# //////------------------------------------------------------------------------
	
	# Create the thumbnail scenario
	var thumbnail_scenario := RenderingServer.scenario_create()	
	
	# Get meshes from scene
	var scene_scrape := _scrape_meshes(thumbnail_scene)
	
	# Initialize array of RIDs to keep track of meshes for later deletion
	var instance_rids := []
	instance_rids.resize(scene_scrape.meshes.size())
	
	var inst_i := 0
	for mesh: Mesh in scene_scrape.meshes:
		# server mesh instance
		instance_rids[inst_i] = RenderingServer.instance_create()
		
		# load the mesh into the server mesh instance, and assign it to the scenario
		RenderingServer.instance_set_base(instance_rids[inst_i], mesh.get_rid())
		RenderingServer.instance_set_scenario(instance_rids[inst_i], thumbnail_scenario)
	
		# cycle to next instance
		inst_i += 1


	# Create the viewport, associate it to a scenario
	# setup render stuff
	var viewport_rid := RenderingServer.viewport_create()
	RenderingServer.viewport_set_scenario(viewport_rid, thumbnail_scenario)
	RenderingServer.viewport_set_disable_2d(viewport_rid, true)
	RenderingServer.viewport_set_disable_3d(viewport_rid, false)
	RenderingServer.viewport_set_transparent_background(viewport_rid, true)
	RenderingServer.viewport_set_size(viewport_rid, size, size)
	RenderingServer.viewport_set_update_mode(
		viewport_rid, 
		RenderingServer.VIEWPORT_UPDATE_ONCE
	)
	
	# Add camera, associate it to the viewport, 
	# set the transform from largest bounds found in the scene scrape.
	var camera_rid := RenderingServer.camera_create()
	RenderingServer.viewport_attach_camera(viewport_rid, camera_rid)
	RenderingServer.camera_set_transform(camera_rid, _get_camera_transform(scene_scrape.largest_bounds))
	
	
	# Environment
	var env_rid := RenderingServer.environment_create()
	RenderingServer.environment_set_background(env_rid, RenderingServer.ENV_BG_COLOR)
	RenderingServer.environment_set_bg_color(env_rid, BG_COLOR)
	RenderingServer.scenario_set_environment(thumbnail_scenario, env_rid)
	
	# Setup viewport for rendering
	RenderingServer.viewport_set_active(viewport_rid, true)
	
	# Manually trigger DRAW!!!
	RenderingServer.force_draw(true, 0.0)
	
	# Wait for the image to finish baking...
	#await RenderingServer.frame_post_draw
	
	# Grab the freshly baked image
	var image_rid := RenderingServer.viewport_get_texture(viewport_rid)
	var image := RenderingServer.texture_2d_get(image_rid)



	# CLEANUP
	# Free everything in the opposite order as it was created
	# //////------------------------------------------------------------------------
	
	
	# Free viewport/camera/env
	RenderingServer.free_rid(viewport_rid)
	RenderingServer.free_rid(camera_rid)
	RenderingServer.free_rid(env_rid)
	
	# Free meshes
	for mesh_rid in instance_rids:
		RenderingServer.free_rid(mesh_rid)
	
	# Free scenario
	RenderingServer.free_rid(thumbnail_scenario)
	
	# Free scene instance
	thumbnail_scene.free()
	
	# Wrap into texture and send back.
	return ImageTexture.create_from_image(image)



# Setup common scene
#light.rotate_x(-90)

## Dict: Array[Mesh], Largest Bounds
static func _scrape_meshes(node: Node) -> Dictionary:
	var base_dict := {
		"meshes" = [],
		"largest_bounds" = Vector3.ZERO
	}
	return _recursive_mesh(node, base_dict)

static func _recursive_mesh(node: Node, dict: Dictionary) -> Dictionary:
	if node is MeshInstance3D:
		dict.meshes.push_back(node.mesh)
		dict.largest_bounds = _get_largest_bounds(
			node as MeshInstance3D, 
			dict.largest_bounds
		)
	
	for child in node.get_children():
		_recursive_mesh(child, dict)
	
	return dict



static func _get_camera_transform(largest_bounds: Vector3) -> Transform3D:
	var origin := Vector3.UP * maxf(largest_bounds.x, largest_bounds.z) + (Vector3(0.5, 0.0, 0.5) * largest_bounds.length())
	var basis := Basis.IDENTITY.rotated(Vector3.LEFT, deg_to_rad(-90)) # look forward
	
	# Look at center
	var t := Transform3D(basis, origin)
	t = t.looking_at(Vector3.ZERO)
	
	return t

static func _get_largest_bounds(node: MeshInstance3D, largest_bounds: Vector3) -> Vector3:
	if node is MeshInstance3D:
		var aabb = node.get_aabb()
		var x = absf(aabb.size.x)
		var y = absf(aabb.size.y)
		var z = absf(aabb.size.z)
		
		if x > largest_bounds.x:
			largest_bounds.x = x
		if y > largest_bounds.y:
			largest_bounds.y = y
		if z > largest_bounds.z:
			largest_bounds.z = z
	
	return largest_bounds
