## Everything Related to placing / removing / moving blocks in voxel space
extends BuildEditorVoxelPicker

# Global classes could mess with other inventory systems
const HotbarSlotClass := preload("uid://c3gbjrpb1kigc")
const InventoryItemClass := preload("uid://cefxuwu6yxry7")

@export_group("Packed References")
@export var packed_block_item: PackedScene
@export var packed_hotbar_slot: PackedScene

@export_group("Internal References")
@export var inventory_foldable: FoldableContainer
@export var inventory_container: Container
@export var hotbar_container: Container
@export var hotbar_preset_switcher: MenuButton


## To avoid rebaking the pictures for every item change
## TODO: I should also set a limit to this and delete stuff not on screen??
var block_thumbnail_cache: Dictionary[int, ImageTexture]


func _enter_tree() -> void:
	#region Build inventory
	for n in inventory_container.get_children():
		n.free()
	
	for i in range(Junk.BLOCK_REGISTRY.defs.size()):
		var def := Junk.BLOCK_REGISTRY.defs[i]
		block_thumbnail_cache[i] = ThumbnailGenerator.generate_thumbnail( def.make_preview_scene() )
		
		var item := packed_block_item.instantiate() as InventoryItemClass
		item.block_index = i
		item.texture_thumbnail.texture = block_thumbnail_cache[i]
		inventory_container.add_child(item)
	#endregion
	
	
	#region Build hotbar
	for n in hotbar_container.get_children():
		n.free()
	for i in range(Junk.EDITOR_HOTBAR_SLOTS):
		var hb_slot := packed_hotbar_slot.instantiate() as HotbarSlotClass
		hotbar_container.add_child(hb_slot)
		
		hb_slot.updated.connect(_on_hotbar_slot_updated)
		hb_slot.selected.connect(_on_hotbar_slot_selected)
	
		#region Imaginary Hotbar Presets loading
		# TODO: Need to add user settings savefile
		
		
		#endregion
	
	
		# Set preview texture if the hotbar is configured
		if hb_slot.block_index != -1:
			hb_slot.preview_texture = block_thumbnail_cache[hb_slot.block_index]
	#endregion


func process_input(event: InputEvent) -> void:
	super.process_input(event)
	
	if event is InputEventKey:
		if event.keycode == Key.KEY_SPACE and (event.pressed and not event.is_echo()):
			inventory_foldable.folded = !inventory_foldable.folded


#region Signals
func _on_block_item_selected(item: InventoryItemClass) -> void:
	_start_action( PlaceBlockAction.new(item.block_index) )


func _on_hotbar_slot_selected(slot: HotbarSlotClass) -> void:
	if slot.block_index == -1: # slot bar can be empty, items are always valid (unless the memory goes through a portal)
		return
	_start_action( PlaceBlockAction.new(slot.block_index) )


func _on_hotbar_slot_updated(slot: HotbarSlotClass) -> void:
	slot.preview_texture = block_thumbnail_cache[ slot.block_index ] if slot.block_index != -1 else null
#endregion


class PlaceBlockAction extends BuildEditorVoxelPicker.Action:
	var block_index: int
	var block_preview: Variant
	
	func _init(block_index: int) -> void:
		self.block_index = block_index
