

void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
	local entity	trigger;
	local vector	tmin, tmax;

//
// middle trigger
//	
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;
	
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	sound (self, chan_no_phs_add|CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom =
{
	sound (self, chan_no_phs_add|CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch =
{
	if (other.classname != "player")
		return;
		
	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == STATE_BOTTOM)
		plat_go_up ();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};

void() plat_outside_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
		
//dprint ("plat_outside_touch\n");
	self = self.enemy;
	if (self.state == STATE_TOP)
		plat_go_down ();
};

void() plat_trigger_use =
{
	if (self.think)
		return;		// allready activated
	plat_go_down();
};


void() plat_crush =
{
//dprint ("plat_crush\n");

	T_Damage (other, self, self, 1, MOD_SQUISH);
	
	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
	else
		objerror ("plat_crush: bad self.state\n");
};

void() plat_use =
{
	self.use = SUB_Null;
	if (self.state != STATE_UP)
		objerror ("plat_use: not in up state");
	plat_go_down();
};


/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/


void() func_plat =

{

	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;
// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}


	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;
	if (!self.speed)
		self.speed = 150;

// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	if (self.height)
		self.pos2_z = self.origin_z - self.height;
	else
		self.pos2_z = self.origin_z - self.size_z + 8;

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	if (self.targetname)
	{
		self.state = STATE_UP;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = STATE_BOTTOM;
	}
};

//============================================================================

void() train_next;
void() func_train_find;

void() train_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg, MOD_SQUISH);
};

void() train_use =
{
	if (self.think != func_train_find)
		return;		// already activated
#ifdef HALFLIFE
	if (#HL_MAP) {
		if (self.target == "waterpath2" || self.targetname == "water_door_move3") {
			self.solid = 1;
		}
	}
	self.has_tesla = 0;
#endif
	train_next();
};

void() train_wait =
{
#ifdef HALFLIFE
	if (self.has_tesla == 1) {
		self.use = train_use;
		self.think = func_train_find;
		self.has_tesla = 0;
		return;
	}
	if (self.message) {
		Delayed_Timer( self.message, 0 );
		self.message = "";
	}
#endif
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		sound (self, chan_no_phs_add|CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
#ifdef HALFLIFE
		if (#HL_MAP)
			train_next();
		else
#endif
		self.nextthink = self.ltime + 0.1;
	
	self.think = train_next;
};

void() train_next =
{
	local entity	targ;

	if (self.has_tesla == 1){
		train_wait();
		return;
	}
	
	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target) {
#ifdef HALFLIFE
		if (#HL_MAP)
		{
			if (targ == world  || !targ.classname || !targ.targetname)
				return;
		}
		else
#endif
		objerror ("train_next: no next target");
	}
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
#ifdef HALFLIFE
	if (self.mtf_items > 0) {
#ifdef SVEN_COOP

/*
		if (mapname == "c2a4c")
			self.speed = self.mtf_items * .75;
		else
		*/
#endif
			self.speed = self.mtf_items;
		self.mtf_items = 0;
	}
	if (#HL_MAP) {//self.globalname)
	
		/*if (self.has_tesla == 1) {
			self.use = train_use;
			return;
		}*/
		if (targ.speed > 0)			// change our speed to match the path_corner's
			self.mtf_items = targ.speed;
		if (targ.spawnflags & 1) {
			self.has_tesla = 1;		// wait till triggered again
		}
		if (targ.message)
			self.message = targ.message;

		if (targ.spawnflags & 2) {	// teleport there auto
			setorigin(self, targ.origin - ((self.mins+self.maxs)*.5));
			SUB_CalcMove(targ.origin - ((self.mins+self.maxs)*.5), 9999, train_wait);
		}
		else
			SUB_CalcMove(targ.origin - ((self.mins+self.maxs)*.5), self.speed, train_wait);
	}
	else
#endif
	SUB_CalcMove (targ.origin - self.mins, self.speed, train_wait);
};

void() func_train_find =

{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
#ifdef HALFLIFE
	if (targ.speed > 0)
		self.speed = targ.speed;
	if (#HL_MAP) {//self.globalname) {
		setorigin(self, targ.origin - ((self.mins + self.maxs)*.5));
		//if (mapname == "c1a0e")
		//	setorigin(self, targ.origin);
		//else
		//	setorigin(self, ((targ.absmax+targ.absmin)*.5) - ((self.absmax+self.absmin)*.5));
		
	}
	else
#endif
	setorigin (self, targ.origin - self.mins);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};

/*QUAKED func_train (0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
void() func_train =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target) {
#ifdef HALFLIFE
		if (self.targetname == "c1a3_pole01") {
			dremove(self);
			return;
		}
#endif
		objerror ("func_train without a target");
	}
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

#ifdef HALFLIFE
	if (mapname == "c1a1b" || mapname == "c1a1c") {
		if (self.globalname == "c1a1b_zombie_vent1")
			dremove(self);
	}
	else if (mapname == "c1a1c") {
		self.globalname = "downward_vent";
	}
	else if (mapname == "c1a2c")
		if (self.target == "freezer_train_2")
			self.globalname = "halflife_thing";
	
	if (#HL_MAP) {
		if (self.spawnflags & 8) {	// swimmy!
			self.spawnflags = 8;
			self.solid = 1;
			setorigin (self, self.origin);
			self.touch = liquid_touch; // better swim function is required lol
		}
		else
			self.spawnflags = 0;		// halflife trains only have "8" for spawn flags afaik
	}
	if (#HL_MAP) {
		if (self.target == "waterpath2" || self.targetname == "water_door_move3") {
			self.solid = 0;
			setorigin(self, self.origin - '0 0 1000');
		}
	}
	HalfLife_DoRender();
#endif
	
// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

/*QUAKED misc_teleporttrain (0 .5 .8) (-8 -8 -8) (8 8 8)
This is used for the final bos
*/
void() misc_teleporttrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

