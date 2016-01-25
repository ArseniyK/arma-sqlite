import std.c.windows.windows;
import core.sys.windows.dll;
import std.stdio;
import std.string;
import std.conv;
import std.exception;
import util.log;
import sqlite.database;
import std.base64;

__gshared HINSTANCE g_hInst;

string db_name;
Log log;
Database db;

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) {
	final switch (ulReason) { 
		case DLL_PROCESS_ATTACH:
			g_hInst = hInstance;
			dll_process_attach(hInstance, true);
			log = Log(fileLogger("logs/armasqlite.log"));
			log.info("Init armasqlite extension");
			try
			{
				File f =File("armasqlite.cfg", "r");
				db_name = chomp(f.readln);
				log.info("Connect to %s", db_name);
				db = new Database(db_name);
			}
			catch (Exception exception)
			{
				log.fatal(exception);
			}		
			break;
 
		case DLL_PROCESS_DETACH:
			dll_process_detach(hInstance, true);
			break;
 
		case DLL_THREAD_ATTACH:
			dll_thread_attach(true, true);
			break;
 
		case DLL_THREAD_DETACH:
			dll_thread_detach(true, true);
			break;
	}
 
	return true;
}
  
export extern (Windows) void RVExtension(char* output, int output_size, const char* cinput) {
	try	{		
		auto dinput = to!string(cinput);
		auto doutput = output[0 .. output_size];
		string result;
		string[] command = dinput.split(";");
		Variant arg;
		switch (command[0]) {
			case "version":
				result = "0.1";
				break;
			case "db":
				result = db_name;
				break;
			case "add_player":
				string query = format("INSERT OR IGNORE INTO players (uid) VALUES ('%s')", command[1]);
				log.info("%s", query);
				db.command(query);
				break;
			case "show_hangar":
				string query = format("select vehicle, count(vehicle) from hangar where uid='%s' group by vehicle", command[1]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString ~ ":";
				if( result.length > 0 )
					result = result[ 0 .. $ -1 ];
				break;
			case "count_hangar":
				string query = format("select count(vehicle) from hangar where uid='%s'", command[1]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "add_to_hangar":
				string query = format("INSERT INTO hangar (uid, vehicle) VALUES ('%s', '%s')", command[1], command[2]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				break;
			case "remove_from_hangar":
				string query = format("DELETE from hangar WHERE id in (Select id from hangar Where uid is '%s' and vehicle is '%s' limit 1)", command[1], command[2]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				break;
			case "get_player_score":
				string query = format("SELECT score FROM players WHERE uid='%s'", command[1]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "set_player_score":
				string query = format("UPDATE players SET score=%s WHERE uid='%s'",  command[2], command[1]);
				log.info("%s", query);
				db.command(query);
				break;
			case "get_pilot_points":
				string query = format("SELECT pilot_points FROM players WHERE uid='%s'", command[1]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "set_pilot_points":
				string query = format("UPDATE players SET pilot_points=%s WHERE uid='%s'",  command[2], command[1]);
				log.info("%s", query);
				db.command(query);
				break;
			case "get_player_weapons":
				string query = format("SELECT weapons FROM players WHERE uid='%s'", command[1]);
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "set_player_weapons":
				string query = format("UPDATE players SET weapons='%s' WHERE uid='%s'",  command[2], command[1]);
				log.info("%s", query);
				db.command(query);
				result = db_name;
				break;
			case "get_mission_state":
				string query = "SELECT finished FROM mission WHERE id=1";
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "set_mission_state":
				string query = format("INSERT OR REPLACE INTO mission (id, finished) VALUES (1, '%s')", command[1]);
				log.info("%s", query);
				db.command(query);
				result = db_name;
				break;
			case "get_target":
				string query = "SELECT target FROM mission WHERE id=1";
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				break;
			case "set_target":				
				string query = format("UPDATE mission SET target='%s' WHERE id=1", command[1]);
				log.info("%s", query);
				db.command(query);
				result = db_name;
				break;
			case "get_targets":
				string query = "SELECT targets FROM mission WHERE id=1";
				log.info("%s", query);
				Row[] results2 = db.command(query);
				foreach( row; results2 )
					result ~= row.toString;
				result = cast (string) Base64.decode(result);
				break;
			case "set_targets":				
				string query = format("UPDATE mission SET targets=%s WHERE id=1", Base64.encode(cast (ubyte[]) command[1]));
				log.info("%s", query);
				db.command(query);
				result = db_name;
				break;			
			case "clear":
				string query = "DELETE FROM players";
				log.info("%s", query);
				db.command(query);
				result = db_name;
				break;
			case "exec":
				log.info("%s", command[1]);
				Row[] results2 = db.command(command[1]);
				result = "[";
				foreach( row; results2 )
					result ~= row.toString ~ ",";
				result ~= "]";
				break;	
			default: result = dinput;
		}		 
		enforce(result.length <= output_size, "Output length too long");
		doutput[0 .. result.length] = result[];
		doutput[result.length] = '\0';
	}
	catch (Exception exception) {
		log.fatal(exception);
	}

}