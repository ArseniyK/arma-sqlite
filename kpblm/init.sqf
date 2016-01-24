kpblm_add_Score = {
	(_this select 0) addscore (_this select 1);
	"kpblm" callExtension format["set_player_score;%1;%2", getPlayerUID (_this select 0), score (_this select 0)];
};
kpblm_get_score = {
	"kpblm" callExtension format["get_player_score;%1", getPlayerUID _this];
};
kpblm_version = {
	"kpblm" callExtension "version";
};
kpblm_db_name = {
	"kpblm" callExtension "db";
};
kpblm_get_weapons = {
	"kpblm" callExtension format["get_player_weapons;%1", getPlayerUID _this];
};
kpblm_set_weapons = {
	"kpblm" callExtension format["set_player_weapons;%1;%2", getPlayerUID (_this select 0), _this select 1];
};
kpblm_isfinished = {
	private "_result";
	_result = "kpblm" callExtension "get_mission_state";
	_result = if (_result == "null" or _result == "false") then {false} else {true};
	_result;
};
kpblm_finished = {
	"kpblm" callExtension format["set_mission_state;%1", _this];	
};
kpblm_add_player = {	
	"kpblm" callExtension format["add_player;%1", getPlayerUID _this];
};
kpblm_clear = {
	"kpblm" callExtension "clear";	
};
kpblm_save_targets = {
	"kpblm" callExtension format["set_targets;%1",_this];
};
kpblm_save_target = {
	"kpblm" callExtension format["set_target;%1",_this];
};
kpblm_get_targets = {
	"kpblm" callExtension "get_targets";	
};
kpblm_get_target = {
	"kpblm" callExtension "get_target";
};
kpblm_set_pilot_points = {	
	"kpblm" callExtension format["set_pilot_points;%1;%2", getPlayerUID (_this select 0),(_this select 1)];
};
kpblm_get_pilot_points = {
	"kpblm" callExtension format["get_pilot_points;%1", getPlayerUID _this];
};
kpblm_show_hangar = {
	private "_result";
	private "_string";
	_result = [];
	_string = "kpblm" callExtension format["show_hangar;%1", getPlayerUID _this];
	{ result = result + [([_x, " "] call CBA_fnc_split)]} forEach ([_string, ":"] call CBA_fnc_split);
	_result;
};
kpblm_add_to_hangar = {
	"kpblm" callExtension format["add_to_hangar;%1;%2", getPlayerUID (_this select 0), (_this select 1)];
};
kpblm_remove_from_hangar = {
	"kpblm" callExtension format["remove_from_hangar;%1;%2", getPlayerUID (_this select 0), (_this select 1)];
};