// by ALIAS
// nul = [obj_nuke,radius] execvm "AlNuke\damage_nuke.sqf";

if (!isServer) exitWith {};

	_mark_x = _this select 0;
	_radius_x =  _this select 1;
	_npos = [getpos _mark_x select 0, getpos _mark_x select 1, 0];
	_obj_x = nearestObjects [_npos, [/*"building","man","car","tank"*/], _radius_x];
	{if (_x !=_mark_x) then {_x setDamage [1,false];};} foreach _obj_x;
	_holders = nearestObjects [_npos,["GroundWeaponHolder"], _radius_x];
	{deleteVehicle _x} forEach _holders;