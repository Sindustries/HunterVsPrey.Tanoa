/*
	HVP Event Manager
	By Sinbane
	Loads events and keeps them running
*/
private ["_time","_airDropHeliSelection","_heliCrashSelection","_uavSelection","_cfg","_i","_cfgName"];
//-----------------------------------
//-DEFINABLE

_time = ["HVPEventTime"] call HVP_fnc_getSetting;
HVPEventTime = (_time * 60);

[] spawn {
	while {true} do {
		HVP_commonEvent = (HVPEventTime+(random HVPEventTime)-(random HVPEventTime));
		HVP_uncommonEvent = (HVPEventTime*1.5+(random HVPEventTime)-(random HVPEventTime));
		HVP_rareEvent = (HVPEventTime*2+(random HVPEventTime)-(random HVPEventTime));
		sleep 30;
	};
};

sleep 20;
//-----------------------------------
//-LOAD EVENTS
if (isServer) then {

//Airdrop Heli selection
_airDropHeliSelection = [];
_cfg = (configFile >> "CfgVehicles");
for "_i" from 0 to ((count _cfg)-1) do {
	if (isClass (_cfg select _i)) then {
		_cfgName = configName (_cfg select _i);			
		if (_cfgName isKindOf "Helicopter" && (getNumber ((_cfg select _i) >> "scope") == 2) && (getNumber ((_cfg select _i) >> "isUav")) == 0 && (getNumber ((_cfg select _i) >> "slingLoadMaxCargoMass") >= 500)) then {
			_airDropHeliSelection pushBackUnique _cfgName;
		};
	};
};

//HeliCrash Heli selection
_heliCrashSelection = [];
_cfg = (configFile >> "CfgVehicles");
for "_i" from 0 to ((count _cfg)-1) do {
	if (isClass (_cfg select _i)) then {
		_cfgName = configName (_cfg select _i);			
		if (_cfgName isKindOf "helicopter" && (getNumber ((_cfg select _i) >> "scope") == 2) && (getNumber ((_cfg select _i) >> "isUav")) == 0) then {
			_heliCrashSelection pushBackUnique _cfgName;
		};
	};
};

//UAV selection
_uavSelection = [];
_cfg = (configFile >> "CfgVehicles");
for "_i" from 0 to ((count _cfg)-1) do {
	if (isClass (_cfg select _i)) then {
		_cfgName = configName (_cfg select _i);			
		if (_cfgName isKindOf "Air" && (getNumber ((_cfg select _i) >> "scope") == 2) && (getNumber ((_cfg select _i) >> "isUav")) == 1) then {
			_uavSelection pushBackUnique _cfgName;
		};
	};
};

//-----------------------------------
//-AIRDROPS

	[_airDropHeliSelection] spawn {
		private "_dropPos";
		waitUntil {sleep 5; HVP_phase_num >= 1};

		while {true} do {
			if (HVPLegacyMode isEqualTo 0) then {
				sleep HVP_commonEvent;
			} else {
				sleep ((HVP_commonEvent)/2);
			};
			_dropPos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			["event",(_this select 0),_dropPos] call HVP_fnc_airdrop;
		};
	};
	
//-----------------------------------
//-DROP POD

	[] spawn {
		private "_dropPos";
		waitUntil {sleep 5; HVP_phase_num >= 1};

		while {true} do {
			sleep HVP_uncommonEvent;
			_dropPos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			[_dropPos] call HVP_fnc_dropPod;
		};
	};

//-----------------------------------
//-HELICRASH

	[_heliCrashSelection] spawn {
		private "_helicrash_pos";
		waitUntil {sleep 5; HVP_phase_num >= 1};
		
		while {true} do {
			sleep HVP_rareEvent;
			_helicrash_pos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			[(_this select 0),_helicrash_pos] call HVP_fnc_heliCrash;
		};
	};

//-----------------------------------
//-ARTILLERY

	private ["_vehCount","_missileCount"];
	
	_vehCount = 4;
	_missileCount = 12;

	[_vehCount,_missileCount] spawn {
		private ["_artyPos","_vehCount","_missileCount"];

		_vehCount = _this select 0;
		_missileCount = _this select 1;

		while {true} do {

			waitUntil {sleep 5; HVP_phase_active isEqualTo "true"};
			sleep HVP_uncommonEvent;
			
			_artyPos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			[_artyPos,_vehCount,_missileCount] call HVP_fnc_artillery;
		};
	};
	
//-----------------------------------
//-CHEMICAL ATTACK

	[] spawn {
		private ["_size","_gasCount","_chemPos"];
		while {true} do {
			waitUntil {sleep 5; HVP_phase_active isEqualTo "true"};
			sleep HVP_commonEvent;
			
			_size = (HVP_Phase_Radius * 0.05);
			_gasCount = (_size / 1.25);
			
			_chemPos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			[_chemPos,_size,_gasCount] call HVP_fnc_chemAttack;
		};
	};

//-----------------------------------
//-QUAKE

	[] spawn {
		private ["_quakePos"];
		waitUntil {sleep 5; HVP_phase_num >= 1};
		
		while {true} do {
			sleep HVP_uncommonEvent;
			
			_quakePos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,1,0,0] call SIN_fnc_findPos;
			[_quakePos] call HVP_fnc_quake;
		};
	};
	
//-----------------------------------
//-NUKE	
	
	[] spawn {
		private ["_nukePos","_nuke"];
		waitUntil {sleep 5; HVP_phase_num >= 1};
		
		while {true} do {
			sleep HVP_rareEvent;
			
			_nukePos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			_nuke = createVehicle ["I_UAV_01_F",_nukePos, [], 0, "NONE"];
			_nuke hideObjectGlobal true;
			[_nuke,(HVP_phase_radius * 0.2),true,true,true,true] call HVP_fnc_nuke;

			sleep HVP_uncommonEvent;
		};
	};
	
//-----------------------------------
//-UAV

	[_uavSelection] spawn {
		private ["_temp","_uavScanSize","_uavTime","_uavUpdate","_uavScanPos","_uavSpawnPos"];
		sleep 1;
		deleteVehicle _temp;
		
		while {true} do {
		
			waitUntil {sleep 5; HVP_phase_active isEqualTo "true"};
			sleep HVP_rareEvent;
			
			_uavScanSize = (HVP_Phase_Radius * 0.2);
			_uavTime = 60 +(random HVPPhaseTime);
			_uavUpdate = 3;
			
			_uavScanPos = [HVP_phase_pos,0,(HVP_phase_radius * 0.9),0,0,0,0] call SIN_fnc_findPos;
			_uavSpawnPos = [_uavScanPos,400,800,0,0,0,0] call SIN_fnc_findPos;
			[(_this select 0),_uavScanPos,_uavSpawnPos,_uavScanSize,_uavTime,_uavUpdate] call HVP_fnc_uav;
		};
	};

//-----------------------------------
};
//-----------------------------------
//-PARANORMAL

HVPParanormalEvent = ["HVPParanormalEvent"] call HVP_fnc_getSetting;
if (HVPParanormalEvent isEqualTo 1 && playerSide != sideLogic) then {
	[] spawn HVP_fnc_paranormal;
};

//-----------------------------------