/*
	HVP Drop Pod Spawn
	Author: Sinbane
	Spawns the player(s) in a Taru Pod that plummets to the ground
*/
private ["_pos","_posFound","_posCheck","_side","_pod","_light","_index","_crater","_fire","_alarm","_sparks1","_sparks2"];
//-----------------------------------
//-POS

_pos = _this select 1;

//-----------------------------------
//-CREATE POD

_pod = createVehicle ["Land_Pod_Heli_Transport_04_covered_F", [(_pos select 0),(_pos select 1),(1500 + (random 1000))],[], 0, "NONE"];
_pod allowDamage false;
_pod lock true;
_pod setDir (random 360);
clearItemCargoGlobal _pod;
clearMagazineCargoGlobal _pod;
clearBackpackCargoGlobal _pod;
clearWeaponCargoGlobal _pod;
_light = createVehicle ["Land_Flush_Light_red_F", (getPos _pod),[], 0, "NONE"];
_light attachTo [_pod, [0,0,0.7]];

//-----------------------------------
//-MOVE PLAYER INTO POD

sleep 1;
player moveInCargo [_pod, 2];
player allowDamage false;
player setVariable ["HVP_spawned", true, true];

//-----------------------------------
//- WAIT UNTIL CRASH

waitUntil {isTouchingGround _pod};
[_pod,["vehicle_collision",350]] remoteExec ["say3D", 0];
_pod setDamage 0.97; // test_EmptyObjectForSmoke // test_EmptyObjectForFireBig
_crater = createVehicle ["CraterLong_small", [(getPos _pod select 0),(getPos _pod select 1),0],[], 0, "NONE"];
_fire = createVehicle ["test_EmptyObjectForSmoke", (getPos _pod),[], 0, "NONE"];
_alarm = createSoundSource ["Sound_Alarm", (getPos _pod), [], 0];
_sparks1 = createSoundSource ["Sound_SparklesWreck1", (getPos _pod), [], 0];
_sparks2 = createSoundSource ["Sound_SparklesWreck2", (getPos _pod), [], 0];

_fire attachTo [_pod, [0,0,0.7]];
_alarm attachTo [_pod];
_sparks2 attachTo [_pod];
_sparks1 attachTo [_pod];

[_pod,_alarm,_sparks1,_sparks2,_fire] spawn {
	private ["_alarm","_sparks1","_sparks2","_fire"];
	_pod = _this select 0;
	_alarm = _this select 1;
	_sparks1 = _this select 2;
	_sparks2 = _this select 3;
	_fire = _this select 4;
	sleep 60+(random 60);
	deleteVehicle _alarm;
	_pod allowDamage true;
	_pod setDamage 1;
	sleep (random 120);
	{deleteVehicle _x;} forEach (_fire getVariable ["effects", []]);
	deleteVehicle _fire;
};
waitUntil {velocityModelSpace _pod isEqualTo [0,0,0]};
sleep 1;
{
	_x allowDamage true;
	_x action ["Eject", _pod];
} forEach crew _pod;

//-----------------------------------