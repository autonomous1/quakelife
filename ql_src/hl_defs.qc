// Half-Life 1 definitions and such

//#define SVEN_COOP				// tells quakelife not to rely on landmarks and utilize sven coop map configs/spawn entities


// sprites
//#define ALLOW_HL_SPRITES		// ADDME: when engines besides FTE support HL1 sprites I will re-enable this.

// levels/transitions
float next_transition_use;

// General entity properties
.string globalname;
.string changetarget;
.string globalstate;
.string LightningEnd, LightningStart;
.string TriggerTarget;
.vector rendercolor;
//.float damagetype;
.float rendermode;
.float renderamt;
void () HalfLife_DoRender;
void () SetSpawnObject;
.float spawnobject;			// spawn object on destruction

// timers
void ( string to_trigger, float trig_delay ) Delayed_Timer;

// effects
.float volume;
#define START_ON		1

// breakables
.float material;
.vector dest;

// explosion properties
.float iMagnitude;

// Use properties
.void() hl_use;

// speaker/ambience
.float is_speaker;

// train stuff
.string train;
.string bottomtrack, toptrack, altpath;
//void(vector tdest, float destangle, float tspeed, float angspeed, void() func) SUB_CalcMoveAndRotate;

// master stuff
.string master;
float ( entity t_ent ) has_master;
float ( entity t_ent ) activate_master;

// Landmarks
entity landmark_ent;		// the landmark entity that players enter the game through
float () HalfLife_UseLandmark;
float landmarked;					// tells us that there is a landmark entity in the map being used
.string landmark;

// script stuff
.float m_fMoveTo;
//.float m_flRadius;
//.float radius;
.string m_iszEntity;

// General doors/buttons
.float rotation;
.float locked_sound;
.float initialstate;
.float activated;

//func_rotating
.vector spawnorigin;	// 

// Triggers and such
float useType;
.float triggerstate;

// Misc
.float buoyancy;					// for func_pushable
.vector orig_angles;				// angles that an entity spawns with, generally
.float type;						// used with world_items

// func_tankmortar
.float barrel;						// length of the barrel
.float yawtolerance;
.float pitchtolerance;
.float firerate;

// func_pendulum;
.float m_accel;
.float m_distance;
.float m_time;
.float damp;
.float m_damp;
.float m_maxSpeed;
.float m_dampSpeed;
.vector m_center;
.vector m_start;
.vector g_vecZero;

// func_mortar_field
.string m_iszYController;
.string m_iszXController;
.float m_fControl;
.float m_iCount;
.float m_flSpread;

// crouch
.float crouchflags;
#define CROUCH_OFF			0
#define CROUCH_ON			1
#define CROUCH_TRYSTAND		2

void ( entity rt_ent, float rt_dir, float traveltime, float rtate, float rt_fps ) CreateRotator;
void () HalfLife_SetupLandmark;

//Doors stuff
void() door_use;
void() door_touch;
void() door_killed;
void () Delayed_Use;
void () ladder_touch;
#define ROTATE_X		0
#define ROTATE_Y		1
#define ROTATE_Z		2
#define HL_MAP		cvar("halflifebsp") == 1
					//cvar("sv_map_halflife") == 1

// func_friction
.float friction;
.float friction_time;
.float friction_new;
.float modifier;
					
// Ladder and water stuff (from extras quake mod)
.float fwatershifttime;
.float ladderjump;
.float laddertime;
.float zerogtime;
.float fwatershift;	// more for water
.float oldgravity;
//water
.float outwsound, inwsound, uwmuffle;
void() liquid_touch;
float KILLINFWATER = 64;
float EASEUNDERCURRENT = 16;
.float drag;
.string cshift;

// monster spawner
.void() monstertype;					
.float monstercount;
.float m_imaxlivechildren;		// max spawned ents that can be alive.

// misc monsters
.void() th_sight;
.vector orig_origin;			// monster's original origin (see nihilanth)
.string reachtarget;
					
// megatf coop carry-overs (AKA stuff that i was too lazy to change)
.string monster_string;
.float is_monster;
.float has_tesla;
.float team_no;
.float distance;
.float rv_s_h;
.float mtf_items;
.float current_menu;		// ADDME
.entity building; // sentrygun stuff
#define true 1
#define npc_originalloc				pos1
#define mtf_coop
#define mtf_coop_halflife

// mega turret

// globals used
string ( string str_a, string str_b ) strstr = #221;
float(string filename, float mode) fopen = #110;
void(float handle) fclose = #111;
string(float handle) fgets = #112;
void(float handle, string s) fputs = #113;
float (string s) strlen = #114;
//string(string s1, string s2) strcat = #115;
string(string s, float start, float length) substring = #116;
vector(string s) stov = #117;		// #130 mvdsv xe extension
string(string s) strzone = #118;
void(string s) strunzone = #119; 
float(string s) tokenize = #441;
string(float n) argv = #442;
float() argc = #85;
string (string str, float start, float len) substr = #116;	// #88
string (string str1, ...) strcat = #115; // #89
string(string n) cvar_string;// = #448;
void(vector v1, vector min, vector max, vector v2, float nomonsters, entity forent) tracebox = #90;
void(string s, string eh) changelevel_save = #70;
string(string s) strtoupper = #481;			// DARKPLACES
string(float ccase, float redalpha, float redchars, string str, ...) strconv = #224;		// FTE
float (float n) sin = #60;
float (float n) cos = #61;
#define SOLID_LADDER			20

// hacks
.string sentence;
string ( string cstr ) hl_script_str;
float MOD_HLIFE =			666;

// hldprint: I only used this function for testing various things. You may find calls to it throughout the code, but they are useless now.
//#define HLDPM
void (float nno, string msg) hldprint =
{
#ifdef HLDM
	bprint( nno, msg );
#endif
};
void () compiler_likes_me_so_much_yay =
{
	empty_float = 0;
	self.maxspeed = 0;
	self.light_lev = 0;
	self.wad = "";
};