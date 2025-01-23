extends OmniLight3D

@export var noise: NoiseTexture3D
var time_passed := 0.0

#adds flickering to the light on the player using noise
func _process(delta):
	time_passed += delta
	
	var sampled_noise = noise.noise.get_noise_1d(time_passed * 5)
	sampled_noise = abs(sampled_noise)
	
	light_energy = sampled_noise
	pass
