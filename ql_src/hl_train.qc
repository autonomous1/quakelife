// Half-life-esque train (hackish)
// by avirox
#define track_activated		has_tesla
#define xavior_hack1		mtf_items
#define ttrain_firstactivated	barrel
void() tracktrain_next;
void () func_tracktrain_find;
void() tracktrain_wait = 
{
	//self.nextthink = self.ltime + 0.1;
	//self.think = tracktrain_next;
	
	if (self.pausetime) {
		self.nextthink = self.ltime + .1;
		self.think = tracktrain_wait;
		return;
	}
	// addme: a way to stop the train manually should go here
	tracktrain_next();
};

void() tracktrain_next = 
{
	local entity targ, targ2, targmsg, oself, ent_user;
	local vector endpos, apos;
	targ = find(world, targetname, self.target);
	
	if (self.#xavior_hack1 <= 0) {
		if (self.message) {
		//bprint(2,"message is clear\n");
			targmsg = find(world, targetname, self.message);
			if (targmsg != world) {
				if (targmsg.use) {
					ent_user = spawn();
					ent_user.target = self.message;
					ent_user.target = strzone(ent_user.target);
					oself = self;
					self = ent_user;
					SUB_UseTargets();
					self = oself;
					strunzone(ent_user.target);
					dremove(ent_user);
				}
			}
			self.message = string_null;
		}

		if (self.netname) {
		//bprint(2,"netname is clear\n");
			targmsg = find(world, targetname, self.netname);
			if (targmsg != world) {
				if (targmsg.use) {
					ent_user = spawn();
					ent_user.target = self.netname;
					ent_user.target = strzone(ent_user.target);
					oself = self;
					self = ent_user;
					SUB_UseTargets();
					self = oself;
					strunzone(ent_user.target);
					dremove(ent_user);
					//if (mapname == "c2a2")
					//	dremove(targmsg);
				}
			}
			self.netname = string_null;
		}
	}
	else
	{
	//bprint(2,"MAYBEEEE\n");
		self.netname = "moooooooooooooo";
		self.message = "meeeeeeeeeeeeeee";
		self.#xavior_hack1 -= 1;
	}
	
	if (targ.classname != "path_track") {
		//bprint(2,"train going to a non-path_track classname\n");
		self.think = func_tracktrain_find;
		return;
	}
	else
		self.reachtarget = targ.targetname;
	if (!(targ.#track_activated))
	{
		bprint(2,"Can't move forward - next rail needs power!\n");
		self.think = func_tracktrain_find;
		return;
	}
	//_bprint(targ.targetname, " is track im goin to\n");
	self.target = targ.target;
	if (targ.message)
		self.message = targ.message;
	if (targ.netname)
		self.netname = targ.netname;
/*
	if (!(self.target))
	{
		bprint(2,"no more targets\n");
		self.think = func_tracktrain_find;
		return;
	}
	*/
	if (targ.wait)
	{
		self.wait = targ.wait;
	}
	else
	{
		self.wait = 0;
	}
	self.sounds = 4;

	endpos = targ.origin;	// old (pre-fte): targ.origin - ((self.mins+self.maxs)*.5);
	endpos_z += self.height;
	
	if (targ.speed > 0)
		if (targ.speed != self.speed)
			self.speed = targ.speed;
	SUB_CalcMove(endpos, self.speed, tracktrain_wait);
	
	targ2 = find(world, targetname, targ.target);
	if (targ) {
		apos = vectoangles(targ.origin - self.origin);
		apos_y += 180;
		apos = apos - self.angles;
		if (apos_y > 180)
			apos_y = apos_y - 360;
		
		CreateRotator( self, #ROTATE_Y, .2, apos_y, 85 );
		//self.angles = vectoangles(targ.origin - self.origin);
		//self.angles_y += 180;
	}
};

void () SUB_CalcMoveAndRotateDone;
void() func_tracktrain_find = 
{
	local entity targ, targ2;
	local vector endpos;
	
	local vector orgsv;
	local string orgs, otarg, realnewtarg;
	local entity newtarg;
	local float lastdist;
	
	otarg = self.target;
	
	targ = find(world, targetname, self.target);
	targ2 = find(world, targetname, targ.target);
	self.target = targ.target;
	
	if (self.state > 0) {		// hack
		SUB_CalcMoveAndRotateDone();
		return;
	}
	
	if (targ.classname == "path_track") {
		if (targ2.classname == "path_track") {
			self.angles = vectoangles(targ2.origin - targ.origin);
		}
		else
			self.angles_y += 45;
	}
	
#ifndef SVEN_COOP
	if (cvar_string(self.globalname) != "" && cvar_string(self.globalname) != "0") {
		//FIXME: train needs to find next track properly
		
		// set origin
		orgs = cvar_string(self.globalname);
		tokenize(orgs);
		
		self.origin_x = landmark_ent.origin_x - stof(argv(0));
		self.origin_y = landmark_ent.origin_y - stof(argv(1));
		self.origin_z = landmark_ent.origin_z - stof(argv(2));
		// end set origin
		
		// set angles
		orgs = cvar_string(strcat(self.globalname,"_ang"));
		if (orgs != "0") {
			tokenize(orgs);
			
			self.angles_x = stof(argv(0));
			self.angles_y = stof(argv(1));
			self.angles_z = stof(argv(2));	
		}
		localcmd( "set " );
		localcmd( strcat(self.globalname,"_ang") );
		localcmd( " 0\n" );
		
		if (mapname == "c0a0e")		// map specific hack :(
			self.angles = '0 0 0';
		// end set angles
	
		if (!self.hl_use) {
			newmis = spawn();
			newmis.classname = "DelayedTimer";
			newmis.target = self.targetname;
			newmis.target = strzone(newmis.target);
			newmis.nextthink = time + 2;
			newmis.think = Transition_Use;
		}
			
		if (cvar_string("train_targ") != "0") {
			self.target = cvar_string("train_targ");
		
			// now make sure the target exists..
			newtarg = find(world, targetname, self.target);
			if (!newtarg) {
				lastdist = 9999;		// look for anything closer than this
				newtarg = find(world, classname, "path_track");
				while (newtarg) {
					if (vlen(self.origin - newtarg.origin) < lastdist) {
						lastdist = vlen(self.origin - newtarg.origin);
						realnewtarg = newtarg.targetname;
					}
					newtarg = find(newtarg, classname, "path_track");
				}
				self.target = realnewtarg;
			}
			
		}
		//localcmd( "set " );
		//localcmd( self.globalname );
		//localcmd( " 0\n" );
	}
	else {
#endif
		endpos = targ.origin/* - ((self.mins+self.maxs)*.5)*/;
		endpos_z += self.height;
		setorigin(self, endpos);
#ifndef SVEN_COOP
	}
#endif
	
	//setorigin(self, targ.origin - ((self.mins+self.maxs)*.5));
	//self.origin_z += self.height;



	
	if (!(self.targetname))
	{
		self.nextthink = self.ltime + 0.1;
		self.think = tracktrain_next;
	}
};

void() tracktrain_use = 
{
	if (self.spawnflags & 2) {
		if (self.#ttrain_firstactivated) {
			if (self.pausetime == 0) {
				self.pausetime = 1;
				self.velocity = '0 0 0';
				self.think = SUB_Null;
			}
			else {
				self.pausetime = 0;
				self.think = tracktrain_next;
				self.nextthink = self.ltime + .1;
			}
			return;
		}

		if (self.velocity == '0 0 0') {
			self.#ttrain_firstactivated = #TRUE;
		}
	}

	if (self.think != func_tracktrain_find)
	{
		return;
	}
	tracktrain_next();
};

void () func_tracktrain_touch =
{
	if (other.classname != "player")
		return;
	if (other.current_menu > 0)
		return;
	if (self.current_menu > time)
		return;	
	
	if (self.think == func_tracktrain_find || self.think == SUB_CalcMoveAndRotateDone)
		centerprint(other, "Track Train\n\nStatus:\n> Off <\n  On  \n\n+use the train to activate it!\n" );
	else
		centerprint(other, "Track Train\n\nStatus:\n  Off  \n> On <\n\n\n" );
	
	self.current_menu = time + 1;
};

void () func_tracktrain_damage =
{
	//self.health = 1;
	if (self.think != func_tracktrain_find)
	{
		return;
	}
	
	self.use();
};

void () ttrain_blocked =
{
	if (other.solid == SOLID_NOT)
		dremove(other);			// fte, fix this ;/
		
	T_Damage (other, self, self, self.dmg, MOD_SQUISH);
	//_bprint(" by ", other.classname, "\n");
};

void () func_tracktrain =
{
	if (CheckExistence() == 0)
	{
		dremove(self);
		return;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.target))
	{
		//objerror("func_tracktrain without a target");
	}
	if (!(self.dmg))
	{
		self.dmg = 2;
	}

	//self.cnt = 1;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = ttrain_blocked;
	self.use = tracktrain_use;
	self.classname = "tracktrain";
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

	
	self.nextthink = self.ltime + 0.1;
	self.think = func_tracktrain_find;
	
	if (!(self.spawnflags & 2)) {		// spawnflags == 2 means no user control
		self.touch = func_tracktrain_touch;
		self.max_health = 1;
		self.hl_use = func_tracktrain_damage;
		//self.takedamage = 1;
	}
};

void () path_track_use =
{
	self.#track_activated = 1;
	//bprint(2,"path_track activated.\n");
	
	if (self.altpath)
	{
		self.noise4 = self.target;
		self.target = self.altpath;
		self.altpath = self.noise4;
	}
};

void () path_track =
{
//self.origin+= '0 0 40';
	self.solid = SOLID_NOT;
	if (self.spawnflags & 1)
		self.#track_activated = 0;
	else
		self.#track_activated = 1;
		
	self.use = path_track_use;
};

void () func_trackchange_use;
void () tc_rotating =
{
	local float mvspd, mval;
	local entity oself;
	oself = self;
	self = self.owner;
	
	if (self.height) {
		if (!self.spawnflags & 16) {
			if (self.#track_activated == #TRUE)	// going up
				mval = self.armorvalue;
			else								// going down
				mval = self.armorvalue * -1;
			self.origin_z += mval;
			self.enemy.absmax_z += mval;
			self.enemy.absmin_z += mval;
			self.enemy.origin = ((self.enemy.absmax+self.enemy.absmin)*.5);
		}
	}
	
	if (self.#track_activated == #TRUE)
		mvspd = -1;
	else
		mvspd = 1;
	
	
	self.pos1_y += mvspd;	// only support y-axis rotation at the moment
	
	self.angles = self.pos1;
	self.enemy.angles = self.pos1;
	
	self = oself;
	
	self.health = self.health - 1;
	if (self.health <= 0) {
		oself = self;
		self = self.owner;
		if (self.#track_activated == #FALSE) {
			self.#track_activated = #TRUE;
			self.enemy.target = self.bottomtrack;
		}
		else {
			self.#track_activated = #FALSE;
			self.enemy.target = self.toptrack;
		}
		self.enemy.netname = "neeh";
		self.enemy.message = "naaahhh";
		self.enemy.#xavior_hack1 = 2;
		bprint(2,"MESSAGE'd\n");
		self.use = func_trackchange_use;
		self.enemy.use = tracktrain_wait;
		self = oself;
		dremove(self);
		return;
	}
	
	self.think = tc_rotating;
	self.nextthink = time + .02;
};

// rotate think for a moving entity
void () hl_rotate_think =
{
	local float traveltime;
	local vector delta;
	
	self.owner.avelocity = '0 0 0';
	
	// now make sure we're not far off.. if we are, then "fix" the angle.
	if ( vlen(self.owner.angles - self.owner.finalangle) > 5 ) {
		delta = self.owner.finalangle - self.owner.angles;
		traveltime = vlen (delta) / self.mtf_items;
		CreateRotator( self.owner, #ROTATE_Y, traveltime, delta_y, self.mtf_items );
		//self.owner.angles = self.owner.finalangle;		// FIXME so players dont get stuck


	}
	dremove(self);
	return;
};

//#define ROTATE_X		0
//#define ROTATE_Y		1
//#define ROTATE_Z		2
// CreateRotator: Like SUB_CalcAngleMove, but can be used while a brush is moving without interrupting that movement.
void ( entity rt_ent, float rt_dir, float traveltime, float rtate, float rt_fps ) CreateRotator =
{
	local entity rotator, oself;
	vector delta, destangle;
	oself = self;
	self = rt_ent;
	
	destangle = self.angles;
	destangle_y += rtate;
	delta = destangle - self.angles;
	self.finalangle = destangle;
	self.avelocity = delta * (1 / traveltime);
	
	rotator = spawn();
	rotator.mtf_items = rt_fps;		// mtf_items = fps of angle movement
	//rotator.dest1 = torg;
	//rotator.dest2 = tdest;
	rotator.health = traveltime;
	rotator.armorvalue = rtate;		// how many degrees we rotate
	rotator.think = hl_rotate_think;
	rotator.owner = rt_ent;
	rotator.nextthink = time + traveltime;
	
	self=oself;
}

void() SUB_CalcMoveAndRotateDone = 
{

	if (self.classname == "tracktrain")
	{
	}
	else
		setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
	{
		self.think1();
	}
};

// SUB_CalcMoveAndRotate:
// Move an entity and rotate it at the same time. Entity should finish rotating by the time it reaches its destination.
// For rotation and movement set to different timings, use SUB_CalcMove() and CreateRotator() (see tracktrain_next)
void(vector torg, vector tdest, float rtate, float tspeed, void() func) SUB_CalcMoveAndRotate = 
{
	local vector vdestdelta;
	local float len;
	local float traveltime;
	if (!tspeed)
	{
		objerror("No speed is defined!");
	}
	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveAndRotateDone;
	
	
	vdestdelta = tdest - self.origin;
	len = vlen(vdestdelta);
	traveltime = len / tspeed;
	if (traveltime < 0.030000)
	{
		traveltime = 0.030000;
	}
	
	if (tdest == self.origin || tdest == ((self.absmax+self.absmin)*.5))
	{
		self.velocity = '0 0 0';
		traveltime = 3;
	}
	else {
		self.velocity = vdestdelta * (1 / traveltime);
	}

	self.nextthink = self.ltime + traveltime;
	CreateRotator( self, #ROTATE_Y, traveltime, rtate, 85 );//CreateRotator( self, #ROTATE_Y, traveltime, rtate, 85 );
};

void () tchanger_go_down;
void() tchanger_hit = 
{
	local entity oself;
	oself = self;
	if (self.#track_activated == #FALSE) {
		self.#track_activated = #TRUE;
		if (self.enemy != world)
			self.enemy.target = self.bottomtrack;
	}
	else {
		self.#track_activated = #FALSE;
		if (self.enemy != world)
			self.enemy.target = self.toptrack;
		hldprint(2,"TARGET BOTTOM\n");
	}
	if (self.enemy != world) {
		self.enemy.netname = "neeh";
		self.enemy.message = "naaahhh";
		self.enemy.#xavior_hack1 = 2;
		self.enemy.use = tracktrain_wait;
	}
	
	self.use = func_trackchange_use;
	
	if (self.classname == "func_trackautochange")
	{
		self = self.enemy;
		self.use();
		self = oself;
	}
	
	eprint(self.enemy);
};

void() ttrain_hit_top = 
{
	self.state = 0;
	self.think = func_tracktrain_find;
};

void() ttrain_hit_bottom = 
{
	self.state = 0;
	self.think = func_tracktrain_find;
};

void() tchanger_go_down = 
{
	local entity oself;
	local vector ppos2, ppos3;
	oself = self;

	sound(self, 2, self.noise, 1, 1);
	self.state = 3;
	self.pos2 = self.origin;
	self.pos2_z -= self.height;
	ppos2 = self.pos2;
	SUB_CalcMoveAndRotate(self.origin, ppos2, self.rotation, 200, tchanger_hit);
	
	if (self.enemy != world) {
		self = self.enemy;
		self.use = SUB_Null;
		self.think = SUB_Null;
		self.nextthink = time + 9999;
		self.state = 2;
	self.pos2 = ((self.absmax+self.absmin)*.5);
	self.pos2_z -= oself.height;
	ppos3 = self.pos2;
		SUB_CalcMoveAndRotate(((self.absmax+self.absmin)*.5), ppos3, oself.rotation, 200, ttrain_hit_bottom);	
		self = oself;
	}
};

void() tchanger_go_up = 
{
	local entity oself;
	local vector ppos2;
	oself = self;

	sound(self, 2, self.noise, 1, 1);
	self.state = 2;
	self.pos2 = self.origin;
	self.pos2_z += self.height;
	ppos2 = self.pos2;
	SUB_CalcMoveAndRotate(self.origin, ppos2, self.rotation*-1, 200, tchanger_hit);
	
	if (self.enemy != world) {
		self = self.enemy;
		self.use = SUB_Null;
		self.state = 2;
	self.pos2 = ((self.absmax+self.absmin)*.5);
	self.pos2_z += oself.height;
	ppos2 = self.pos2;
		SUB_CalcMoveAndRotate(((self.absmax+self.absmin)*.5), ppos2, oself.rotation*-1, 200, ttrain_hit_top);	
		self = oself;
	}
};

void () func_trackchange_use =
{
	local float dist;

	local entity targ, targ2;
	targ = find(world, targetname, self.train);
	
	if (!self.#track_activated)	// start top
		targ2 = find(world, targetname, self.toptrack);
	else						// start below
		targ2 = find(world, targetname, self.bottomtrack);

	if (self.classname != "func_platrot") {
		if (targ2 == world) {
			bprint(2, "func_trackchange_use: top and/or bottom track is missing\n");
			return;
		}
		
		if (targ == world) {
			bprint(2, "func_trackchange_use: cannot find train\n");
			return;
		}
	}
	
	dist = vlen(((self.absmax+self.absmin)*.5) - ((targ.absmax+targ.absmin)*.5));
	if (dist > 150 || dist < -150)
	{
		if (self.height) {	// hack
			dist = vlen(targ2.origin - ((targ.absmax+targ.absmin)*.5));
			if (dist > 150 || dist < -150) {
				bprint(2,"train needs to be closer to rotate ent to work properly 2\n");
				return;
			}
		}
		else {
			bprint(2,"train needs to be closer to rotate ent to work properly\n");
			return;
		}

	}
	
	
/*
	newmis = spawn();
	newmis.think = tc_rotating;
	newmis.health = self.rotation;
	self.armorvalue = self.height / self.rotation;
	newmis.owner = self;
	if (newmis.health < 0)
		newmis.health *= -1;
	newmis.nextthink = time + .1;
	
	self.pos1 = self.angles;
	self.enemy = targ;
	self.use = SUB_Null;
	self.enemy.use = SUB_Null;
	*/
	
	self.enemy = targ;
	
	if (self.classname == "func_platrot")
	{
		if (self.#track_activated)	
			tchanger_go_down();
		else						
			tchanger_go_up();
		return;
	}
	//if (self.height) {
		if (self.#track_activated)	// go up
			tchanger_go_up();
		else						// go down
			tchanger_go_down();
/*	}
	else {
		if (self.#track_activated)	// go up
			CreateRotator( self, #ROTATE_Y, 3, self.rotation, 85 );
		else						// go down
			CreateRotator( self, #ROTATE_Y, 3, self.rotation*-1, 85 );
		
	}*/


};

void () func_trackchange_setangles =
{
	local string mtarg;
	local entity targ;
	local vector vang;

	if (self.spawnflags & 8) // start at bottom
	{
		mtarg = self.bottomtrack;
		self.#track_activated = #TRUE;	// top
		self.origin_z -= self.height;
	}
	else {
		mtarg = self.toptrack;
		self.#track_activated = #FALSE;	// bottom
	}
	mtarg = strzone(mtarg);
	
	targ = find(world, targetname, mtarg);
	
	if (targ) {
		vang = vectoangles(targ.origin - self.origin);
		self.angles_y += 180 + vang_y;
	}
	strunzone(mtarg);
	self.think = SUB_Null;
};

void () func_trackchange_touch =
{
	if (other == world || other.classname == "player")
		return;
	
	if (other.solid == SOLID_NOT)		// sometimes we get stuck on non-solids while rotating.. ty FTE ^^
		dremove(other);
	
}

void () func_trackchange =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.use = func_trackchange_use;
	//self.classname = "trackchange";
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
	
	self.touch = func_trackchange_touch;
	
	if (self.classname == "func_platrot")
		return;
	
	// set angles based on where we start (top or bottom)
	if (!self.spawnflags & 8)	// fixme: not sure about this
		self.angles_y += self.rotation;
	self.think = func_trackchange_setangles;
	self.nextthink = time + 1;

}

void () func_platrot =
{
	if (self.height < 0) {
		
		//self.height *= -1;
	}
	if (self.targetname) {	// start top
		self.angles_y += self.rotation;
		self.#track_activated = 1;		// this means start top for platrot, and start bottom for trackchanger.
		self.rotation *= -1;
	}

	func_trackchange();
};
void () func_trackautochange =
{
	func_trackchange();
};
