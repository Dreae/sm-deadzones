## Deadzones

[Download](https://gitlab.com/Dreae/sm-deadzones/-/jobs/artifacts/master/raw/deadzones.smx?job=build)

Allows you to define zones in which players are not allowed to shoot, and can not be shot.
Useful to prevent spawn killing/camping and people shooting out of spawn, which promotes
spawn killing

### Usage

 - Use `!deadzone_place` to begin placing a deadzone (requires change map admin flag)
 - Use `!deadzone_cancel` to cancel placement
 - Use `!deadzone_finish` to finish placement
 - Use `!deadzone_delete` to delete the zone you're currently standing in

Zones are saved by map in `addons/sourcemod/configs/deadzones/{mapName}.txt`