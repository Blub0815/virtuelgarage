private _thisPos = _this select 0;
private _thisDir = _this select 1;

//check garage position isEmpty
private _blocked = false;
{
  if ( (_x distance _thisPos < 15) ) exitwith {_blocked = true;};
}forEach vehicles;

if (_blocked) exitwith {
  hint "Vehicle Spawnpunkt blockiert!";
};
//--

//close any other dialog
closedialog 0;


//create a invisible helipad at the desired garage position
private _thisvehicle = createVehicle [ "Land_HelipadEmpty_F",_thisPos,[],0,"CAN_COLLIDE"]; 

_thisvehicle setPosATL _thisPos;
//--


ugga_garageDir = _thisDir;

["Open",[ true,_thisvehicle]] call BIS_fnc_garage;


uisleep 1;
disableserialization;

uinamespace setVariable ["DORB_Garagenhandler",((uinamespace getVariable "RscDisplayGarage") displayAddEventHandler ["unload", {
    
	/*
    * Entfernen des DisplayEventhandlers
    */
    disableserialization;
    (uinamespace getVariable "RscDisplayGarage") displayRemoveEventHandler ["unload",uinamespace getVariable ["DORB_Garagenhandler",-1]];

	
	[] spawn {
        //uisleep 2;
        /*
        * Auslesen der Daten des Lokalen Garagenobjektes
        */
        private _vehicle = missionNamespace getVariable ["BIS_fnc_garage_center",objNull];
        private _vehiclePos = getPosATL _vehicle;
        private _vehicleType = typeOf _vehicle;
        ([_vehicle] call BIS_fnc_getVehicleCUstomization) params ["_textures","_animations"];
        /*
        * Workaround für mittels Template gespawnte Fahrzeuge (bspw. RHS)
        */
        private _textures_new = getobjecttextures _vehicle;
        
        /*
        * Löschen der evtl gespawnten Crew + des lokalen Fahrzeuges
        */
        {_vehicle deleteVehicleCrew _x} forEach crew _vehicle;
        deleteVehicle _vehicle;
		
		
        /*
        * Kreieren des Multiplayer tauglichen Objektes und drehen des Objektes
        */
        private _newVehicle = createVehicle [_vehicleType, _vehiclePos, [], 0 , "none"];
		_newVehicle setposatl _vehiclePos;
        _newVehicle setDir ugga_garageDir;
		ugga_garageDir = nil;
        [_newVehicle,_textures,_vehicle getVariable ["bis_fnc_initVehicle_animations",_animations]] spawn bis_fnc_initVehicle;
        
        /*
        * Der 2. Teil des Texturen Workarounds
        */
        If (_textures isEqualTo []) then {
            {_newVehicle setObjectTextureGlobal [_forEachIndex,_x];} forEach _textures_new;
        };

    };
}])];
