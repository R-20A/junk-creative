# exports all objects child of the selected collection, 
# neatly organized in folders matching child collections!

import bpy
import os


BASE_FOLDER = ""


# 
def export_collection(collection, basedir):
    # Organize exported files in folders, matching collection names!!
    folder_name = bpy.path.clean_name(collection.name)
    folder_path = os.path.join(basedir, folder_name)

    
    # Export every object in the organized folder
    collection_objects = collection.all_objects

    for obj in collection_objects:

        # So we can actually export the object
        obj.select_set(True)

        # some exporters only use the active object
        view_layer.objects.active = obj

        # make the individual object path
        obj_path_name = bpy.path.clean_name(obj.name)
        obj_file_path = os.path.join(folder_path, obj_path_name)

        # EXPORT!!!
        bpy.ops.wm.obj_export((
            filepath=obj_file_path + ".obj",
            export_selected_objects=True
        )

        # Deselect this object...
        obj.select_set(False)

        print("written:", obj_file_path)


# export to blend file location
basedir = os.path.dirname(bpy.data.filepath)
basedir = os.path.join(basedir, BASE_FOLDER)

if not basedir:
    raise Exception("Blend file is not saved")

# save current selection to restore later
view_layer = bpy.context.view_layer
obj_active = view_layer.objects.active
selection = bpy.context.selected_objects

# get the current collection
exported_collection = bpy.context.collection

if not exported_collection:
    raise Exception("No Collection is selected!!")

# gather all child collections
#child_collections = exported_collection.children

# deselect all objects, we need to export one by one!
bpy.ops.object.select_all(action='DESELECT')


# Export child collections
#for collection in child_collections:


# export this one collection
export_collection(exported_collection, basedir)

# reset selection
view_layer.objects.active = obj_active
for obj in selection:
    obj.select_set(True)