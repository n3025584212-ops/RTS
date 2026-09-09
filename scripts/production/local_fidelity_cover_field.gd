extends Resource
## A shared world-space field controls both plant placement and bare soil.
## A chunk can rebuild this field deterministically without hand-placing blades.
@export var seed_value := 34817
@export var patch_scale_m := 7.5
@export var origin := Vector2(-32,-40)
@export var extent := Vector2(62,68)
@export var resolution := 512
var map: Image
var texture: ImageTexture

func build() -> void:
	var macro := FastNoiseLite.new()
	macro.seed=seed_value
	macro.frequency=1./patch_scale_m
	macro.fractal_octaves=2
	var detail := FastNoiseLite.new()
	detail.seed=seed_value+71
	detail.frequency=.55
	detail.fractal_octaves=2
	map=Image.create(resolution,resolution,false,Image.FORMAT_R8)
	for iz in range(resolution):
		for ix in range(resolution):
			var p:=origin+Vector2(ix,iz)*extent/float(resolution-1)
			var cover:=smoothstep(-.17,.28,macro.get_noise_2d(p.x,p.y)+detail.get_noise_2d(p.x,p.y)*.18)
			# The occupied fence position has a worn approach, without a square cutout.
			var approach:=Vector2((p.x-11.5)/3.2,(p.y-9.0)/2.0).length()
			cover*=lerpf(.06,1.,smoothstep(.55,1.25,approach))
			map.set_pixel(ix,iz,Color(cover,cover,cover))
	texture=ImageTexture.create_from_image(map)

func sample(p: Vector2) -> float:
	var uv:Vector2=(p-origin)/extent
	var pixel:=uv*float(resolution-1)
	var ix:=clampi(int(pixel.x),0,resolution-2)
	var iy:=clampi(int(pixel.y),0,resolution-2)
	var f:=Vector2(clampf(pixel.x-ix,0.,1.),clampf(pixel.y-iy,0.,1.))
	return lerpf(lerpf(map.get_pixel(ix,iy).r,map.get_pixel(ix+1,iy).r,f.x),lerpf(map.get_pixel(ix,iy+1).r,map.get_pixel(ix+1,iy+1).r,f.x),f.y)
