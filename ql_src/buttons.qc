// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
#ifdef HALFLIFE
	if (#HL_MAP)
		if (self.spawnflags & 1) {
			SUB_CalcMove(self.origin, self.speed, button_wait);
			return;
		}
#endif
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
#ifdef HALFLIFE
	if (has_master(self))
		return;
#endif
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
	if (other.classname != "player")
		return;
#ifdef HALFLIFE
	if (has_master(self))
		return;
#endif
	self.enemy = other;
	button_fire ();
};

void() button_killed =
{
#ifdef HALFLIFE
	if (has_master(self)) {
		self.health = 1;
		return;
	}
#endif
	self.enemy = damage_attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
#ifdef HALFLIFE
void() multi_use;
void() trigger_multiple;
#endif
void() func_button =
{
	switch (self.sounds)
	{
	case 0:
		precache_sound ("buttons/airbut1.wav");
		self.noise = "buttons/airbut1.wav";
		break;
	case 1:
		precache_sound ("buttons/switch21.wav");
		self.noise = "buttons/switch21.wav";
		break;
	case 2:
		precache_sound ("buttons/switch02.wav");
		self.noise = "buttons/switch02.wav";
		break;
	case 3:
		precache_sound ("buttons/switch04.wav");
		self.noise = "buttons/switch04.wav";
		break;
	}
	
	SetMovedir ();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
#ifdef HALFLIFE
	if (mapname == "c1a1c") {
		if (self.model == "*113")
			self.target = "changetoc1a2";
	}
	/*
	else if (mapname == "c1a1b") {
		if (self.model == "*2") {
			self.killtarget = "aira";
			self.wait = 2;
			return;
		}
	}
	*/
	else if (mapname == "c1a3d") {
		if (self.target == "c1a3_liftdoor01") {
			newmis = spawn();
			newmis.classname = "trigger_once";
			newmis.wait = -1;
			newmis.delay = 3;
			newmis.targetname = "c1a3_liftdoor01";
			newmis.target = "c1a3_lift01";
			newmis.use = multi_use;
			return;
		}
	}
	else if (mapname == "c1a3a") {
		if (self.target == "c1a3_liftdoor03") {
			newmis = spawn();
			newmis.classname = "trigger_once";
			newmis.wait = -1;
			newmis.delay = 3;
			newmis.targetname = "c1a3_liftdoor03";
			newmis.target = "c1a3_lift02";
			newmis.use = multi_use;
			return;
		}
	}
	else if (mapname == "c2a1a") {
		if (self.target == "p_mm2") {
			self.max_health = 1;
			self.th_die = button_killed;
			self.takedamage = 1;
		}
	}
	self.hl_use = button_use;
	
	HalfLife_DoRender();
#endif
};

