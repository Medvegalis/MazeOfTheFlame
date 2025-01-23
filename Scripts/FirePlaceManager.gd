extends Node3D

class_name FirePlaceManager

@onready var light_source : Light3D = $Fire/OmniLight3D
@onready var flameParticles : GPUParticles3D = $Fire/Flame
@onready var fireNode: Node3D = $Fire
var fireMaterial: ParticleProcessMaterial

func _ready() -> void:
	fireMaterial = flameParticles.process_material
	fireMaterial.scale_max = 1

#updates the size of the fire to time remaining
func update_fire_particles(new_scale : float):
	if new_scale < 0 or fireMaterial == null:
		return
	light_source.light_energy = remap(new_scale, 0, 5, 0, 5)
	fireMaterial.scale_max = new_scale
	
func hide_fireplace_fire():
	fireNode.hide()

func show_fireplace_fire():
	fireNode.show()
