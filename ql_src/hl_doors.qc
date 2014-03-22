void () rot_crush;

float DOOR_REVERSE		= 2;
float DOOR_X_AXIS		= 64;
float DOOR_Y_AXIS		= 128;
//a q2 ent.
void() func_door_rotating =
{

   
	if (world.worldtype == 0)
	{
		precache_sound ("doors/medtry.wav");
		precache_sound ("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else if (world.worldtype == 1)
	{
		precache_sound ("doors/runetry.wav");
		precache_sound ("doors/runeuse.wav");
		self.noise3 = "doors/runetry.wav";
		self.noise4 = "doors/runeuse.wav";
	}
	else if (world.worldtype == 2)
	{
		precache_sound ("doors/basetry.wav");
		precache_sound ("doors/baseuse.wav");
		self.noise3 = "doors/basetry.wav";
		self.noise4 = "doors/baseuse.wav";
	}
	else
	{
		dprint ("no worldtype set!\n");
	}
	if (self.sounds == 0)
	{
		precache_sound ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("doors/drclos4.wav");
		precache_sound ("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/hydro1.wav");
		precache_sound ("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/stndr1.wav");
		precache_sound ("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound ("doors/ddoor1.wav");
		precache_sound ("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}


	if (self.spawnflags & DOOR_X_AXIS)
		self.movedir_z = 1.0;
	else if (self.spawnflags & DOOR_Y_AXIS)
		self.movedir_x = 1.0;
	else // Z_AXIS
		self.movedir_y = 1.0;

	// check for reverse rotation
	if (self.spawnflags & DOOR_REVERSE)
		self.movedir = '0 0 0' - self.movedir;



	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = 7.000;
	setorigin (self, self.origin);  
	setmodel (self, self.model);
	
	/*
  	if (mapname == "c1a4f")
		if (self.targetname == "bucket") {	// hackish
			newmis = spawn();
			newmis.classname = "info_teleport_destination";
			newmis.origin = '-489.4 930.9 -628.7';
			newmis.targetname = "teletarg";
			newmis.targetname = strzone(newmis.targetname);
			self.target = "teletarg";
			self.target = strzone(self.target);
			self.touch = teleport_touch;
			self.nextthink = time + 99999999999;
			self.think = SUB_Null;
			return;
		}
	*/
	self.classname = "door_rotating";

	self.blocked = door_blocked;
	self.use = door_use;
	
/*	if (self.spawnflags & 16.000)
		self.items = 131072;
	if (self.spawnflags & 8.000)
		self.items = 262144;
	*/
	if (!self.speed)
		self.speed = 100;
	if (!self.wait)
		self.wait = 3;
	if (!self.lip)
		self.lip = 8;
	if (!self.dmg)
		self.dmg = 2;

//	self.pos1 = self.origin;
//	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

	self.pos1 = self.angles;
	self.pos2 = self.angles + self.movedir * self.distance;

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if (self.spawnflags & 1.000)
	{
//		setorigin (self, self.pos2);
		self.pos1 = self.pos2;
		self.pos1 = self.angles;
	}

	self.state = 1.000;

	if (self.health)
	{
		self.takedamage = 1.000;
		self.th_die = door_killed;
	}
	
	if (self.items)
		self.wait = -1;
		
	//if (!self.spawnflags & 256)	// use only - but use is touch in quake anyways lol
		self.touch = door_touch;

	self.hl_use = door_use;

	if (self.targetname) {		// Door is locked if it must be triggered
		self.touch = SUB_Null;
		self.th_die = SUB_Null;
		self.hl_use = SUB_Null;
	}	
		
	if (self.spawnflags & 32) {		// Door does not return to original place
		self.th_die = SUB_Null;
	}		

	if (self.spawnflags & 256)	// use only.. which means killable too :p
	{
		self.takedamage = 1;
		self.health = 1;
		self.max_health = 1;
		self.th_die = door_killed;
		self.touch = door_touch;
	}

		
// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	if (!self.spawnflags & 4)
		self.spawnflags += 4;		// so we DONT link doors
	
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
	self.blocked = rot_crush;

	if (mapname == "c2a5g")
		if (self.targetname == "roll")
			self.targetname = "rollcar";
		else if (self.targetname == "kick")
			self.targetname = "kickcar";
};

// addme: add proper support :)
// see: momentary_rot_button
void () momentary_door =
{
	if (!self.spawnflags & 4)
		self.spawnflags += 4;
	func_door();
}