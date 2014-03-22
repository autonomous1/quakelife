void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	
	SUB_UseTargets();

	if (self.wait > 0)	
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed =
{
	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use =
{
#ifdef HALFLIFE
	if (has_master(self) == #TRUE)
		return;
#endif
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{

#ifdef HALFLIFE
	if (!self.spawnflags & 4)
		if (other.classname != "player")
			return;

	if (#HL_MAP)
		if (self.spawnflags & 4)		// Pushables only (c1a0e)
			if (other.classname != "pushwall")
				return;

	if (has_master(self) == #TRUE)
		return;
		

#else
	if (other.classname != "player")
		return;
#endif
	
// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}
	
	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_multiple =
{
	switch (self.sounds)
	{
	case 1:
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
		break;
	case 2:
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
		break;
	case 3:
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
		break;
	}
	
	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
#ifdef HALFLIFE
		if (#HL_MAP)
			self.touch = multi_touch;		// no SPAWNFLAG_NOTOUCH for half-life multi triggers
#endif
	}
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() trigger_once =
{
	self.wait = -1;
#ifdef HALFLIFE
	if (#HL_MAP)
		if (self.target == "init_rocket_fire") {
			self.master = "testfire_ms";
			self.master = strzone(self.master);
		}
#endif
	trigger_multiple();
};

#ifdef HALFLIFE
void () trigger_relay_checktargs =
{
	local entity targ;
	targ = find(world, target, self.targetname);
	
	if (targ == world) {
		targ = find(world, TriggerTarget, self.targetname);
		if (targ != world) {
			if (targ.classname == "env_global") {
				hldprint(2,"No setting of globals!\n");
			}
			hldprint(2, "set proper trigger target!\n");
			targ.target = targ.TriggerTarget;
			return;
		}
		//self.use();
		hldprint(2,"trigger_relay: not targeted by anything\n");
	}
	else {
		hldprint(2, "Am targeted!\n");
	}
};
#endif

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void () trigger_relay_use =
{
	SUB_UseTargets();
};

void() trigger_relay =
{
#ifdef HALFLIFE
	self.use = trigger_relay_use;
	if (self.killtarget == "xentalkmm") {	// lol dont ask
		self.killtarget = "blah";
		dremove(self);
		return;
	}
	// since a lot of things arent implemented yet, make sure this can be triggered, and if not then auto-trigger it..
	if (#HL_MAP) {
		self.think = trigger_relay_checktargs;
		self.nextthink = time + 2;
	}
#else
	self.use = SUB_UseTargets;
#endif
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple ();
};

//=============================================================================


void() counter_use =
{
	self.count = self.count - 1;
	if (self.count < 0)
		return;
	
	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}
	
	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};


/*
==============================================================================

TELEPORT TRIGGERS

==============================================================================
*/

float	PLAYER_ONLY	= 1;
float	SILENT = 2;

void() play_teleport =
{
	local	float v;
	local	string tmpstr;

	v = random();
	if (v < 0.2)
		tmpstr = "misc/r_tele1.wav";
	else if (v < 0.4)
		tmpstr = "misc/r_tele2.wav";
	else if (v < 0.6)
		tmpstr = "misc/r_tele3.wav";
	else if (v < 0.8)
		tmpstr = "misc/r_tele4.wav";
	else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};

void(vector org) spawn_tfog =
{
	local entity s;
	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
	s.think = play_teleport;

	TE_teleport(org);
};


void() tdeath_touch =
{
	if (other == self.owner)
		return;

// frag anyone who teleports in on top of an invincible player
	if (other.classname == "player")
	{
		if (other.invincible_finished > time &&
			self.owner.invincible_finished > time) {
			other.invincible_finished = 0;
			self.owner.invincible_finished = 0;
			T_Damage (other, self, self.owner, 50000, MOD_TELEFRAGDEFLECT);
			T_Damage (self.owner, self, other, 50000, MOD_TELEFRAGDEFLECT);
			return;
		}
			
		if (other.invincible_finished > time)
		{
			T_Damage (self.owner, self, self.owner, 50000, MOD_TELEFRAGDEFLECT);
			return;
		}
		
	}

	if (other.health)
	{
		T_Damage (other, self, self.owner, 50000, MOD_TELEFRAG);
	}
};


void(vector org, entity death_owner) spawn_tdeath =
{
local entity	death;

	death = spawn();
	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;
	
	force_retouch = 2;		// make sure even still objects get hit
};

void() teleport_touch =
{
local entity	t;
local vector	org;
#ifdef HALFLIFE
	if (!HL_MAP)
#endif
	if (self.targetname)
	{
		if (self.nextthink < time)
		{
			return;		// not fired yet
		}
	}

	if (self.spawnflags & PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}

// only teleport living creatures
	if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
		return;

#ifdef HALFLIFE
	if (self.spawnflags & 2)		// No players
		if (other.classname == "player")
			return;
	if (#HL_MAP)
		if (self.spawnflags & 1)		// Allow monsters
			{}
		else
			if (other.classname != "player")
				return;

	if (has_master(self)) {
		//if (!activate_master(self))
			return;
	}
		
	if (self.classname == "monster_nihilanth")
		return;
#endif
		
	SUB_UseTargets ();

// put a tfog where the player was
	spawn_tfog (other.origin);

	t = find (world, targetname, self.target);
	if (!t)
		objerror ("couldn't find target");
		
// spawn a tfog flash in front of the destination
	makevectors (t.mangle);
	org = t.origin + 32 * v_forward;

	spawn_tfog (org);
	spawn_tdeath(t.origin, other);

// move the player and lock him down for a little while
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = (v_forward * other.velocity_x) + (v_forward * other.velocity_y);
		return;
	}

#ifdef HALFLIFE
	if (#HL_MAP)
		setorigin (other, t.origin + '0 0 15');
	else
#endif
	setorigin (other, t.origin);
	other.angles = t.mangle;
	if (other.classname == "player")
	{
		other.fixangle = 1;		// turn this way immediately
		other.teleport_time = time + 0.7;
		if (other.flags & FL_ONGROUND)
			other.flags = other.flags - FL_ONGROUND;
		other.velocity = v_forward * 300;
	}
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.  It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
// this does nothing, just serves as a target spot
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
	if (!self.targetname)
		objerror ("no targetname");
};

void() teleport_use =
{
#ifdef HALFLIFE
//	if (has_master(self))
		//return;
#endif
	self.nextthink = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
	self.think = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity. You must set the "target" field, and create an object with a "targetname" field that matches.

If the trigger_teleport has a targetname, it will only teleport entities when it has been fired.
*/
void() trigger_teleport =
{
	local vector o;

	InitTrigger ();
	self.touch = teleport_touch;
	// find the destination 
	if (!self.target)
		objerror ("no target");
	self.use = teleport_use;

	if (!(self.spawnflags & SILENT))
	{
		precache_sound ("ambience/hum1.wav");
		o = (self.mins + self.maxs)*0.5;
		ambientsound (o, "ambience/hum1.wav",0.5 , ATTN_STATIC);
	}
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	remove (self);
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
#ifdef HALFLIFE
		if (#HL_MAP) {
			if (self.spawnflags & 8) {
				if (other.classname == "player") {
					// dont hurt clients
					self.think = hurt_on;
					self.nextthink = time + 1;
					return;
				}
			}
		}
		if (self.dmg < 0)	// yes, trigger_hurts can heal in half-life O.o
		{
			other.health += -self.dmg;
			if (other.health > other.max_health)
				other.health = other.max_health;
		}
		else
#endif
		T_Damage (other, self, self, self.dmg, MOD_HURT);
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
#ifdef HALFLIFE
void() trigger_hurt_use = 
{
	if (self.touch == hurt_touch) {
		self.touch = SUB_Null;
	}
	else {
		self.touch = hurt_touch;
	}
		
	if (self.spawnflags & 1)
		self.use = SUB_Null;
};
#endif
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;
#ifdef HALFLIFE
	if (#HL_MAP) {
		self.use = trigger_hurt_use;
		if (self.spawnflags & 2)
			self.touch = SUB_Null;
		if (mapname == "c1a3")
			dremove(self);	// doesnt really work right in quakeworld
		if (substr(mapname, 0, 4) == "c2a2" || mapname == "c2a3") {
			if (self.dmg == 10 || self.dmg == 20 || self.dmg == 5 || self.dmg == 150)
				self.touch = SUB_Null;
		}
	}
#endif
};

//============================================================================

float PUSH_ONCE = 1;

void() trigger_push_touch =
{
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
#ifdef HALFLIFE
		if (#HL_MAP) {	// halflife's trigger_push handles these things differently.. more subtle
			//bprint(2,vtos(self.movedir));
			//bprint(2," is my movedir\n");
			other.velocity = other.velocity + (self.speed*.01 * self.movedir);
		}
		else
#endif
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
#ifdef HALFLIFE
void () func_ladder;
void () trigger_push_use =
{
	self.touch = trigger_push_touch;
	self.use = SUB_Null;
};
#endif
void() trigger_push =
{
	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;
#ifdef HALFLIFE
	if (#HL_MAP) {
		if (self.spawnflags & 2) {
			self.use = trigger_push_use;
			self.touch = SUB_Null;
		}
	}

	if (mapname == "c1a1b")
		if (self.targetname == "water_door_current") {
			// ADDME: Make the .use turn this into func_ladder or something
			//self.gravity = 11;
			self.targetname = "blahhh";
			self.use = SUB_Null;
			func_ladder();
			return;
		}
#endif
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;
};

