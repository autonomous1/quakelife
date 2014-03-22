// Rotating buttons and other various rotating entities
void () hl_rotating =
{
	local float mvspd, realmvspd;
	
	// TODO: hm, wouldn't it make sense to calculate the v_angle and then rotate accordingly?
	
	mvspd = 180;
	if (!self.speed)
		realmvspd = 300;
	else
		realmvspd = self.speed;
	
	if (self.spawnflags & 2)
		mvspd = mvspd * -1;
	
	if (self.spawnflags & 4)
		self.pos1_z += mvspd;
	else if (self.spawnflags & 8)
		self.pos1_x += mvspd;
	else {
		//bprint(2,"rotating object with no axis specified\n");
		self.pos1_y += mvspd;
	}
	
	// fixme: add adjustable speed
	SUB_CalcAngleMove (self.pos1, realmvspd, hl_rotating);
};

void () func_rotating_use =
{
	if (self.has_tesla == 0) {
		hl_rotating();
		self.has_tesla = 1;
	}
	else
	{
		self.avelocity = '0 0 0';
		self.think = SUB_Null;
		self.has_tesla = 0;
	}
	//self.use = SUB_Null;
};

void() rot_crush =
{
//dprint ("plat_crush\n");

	T_Damage (other, self, self, 1, MOD_SQUISH);
}
	
void () func_rotating =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;

	HalfLife_DoRender();
	
	self.blocked = rot_crush;
	if (self.spawnflags & 64)
	{
		self.solid = 0;
	}
	else
	{
		self.solid = 4;
		//self.blocked = movewall_blocked;
	}
	
	if (mapname == "c3a1a")
		if (self.speed == 35)
			self.solid = 0;
	
	// HACK
	if (mapname == "c1a1f" && self.classname == "func_rotating")
		self.solid = SOLID_NOT;
	
	setmodel(self, self.model);
	//SetMovedir();
	//self.pos1 = self.origin;
	//self.pos2 = self.pos1 + self.movedir/* * (fabs(self.movedir * self.size) - self.lip)*/;
	if (self.spawnflags & 1) {	// start on
		func_rotating_use();
	}

	self.use = func_rotating_use;


	if (self.spawnorigin != '0 0 0')
		setorigin(self, self.spawnorigin);
	//self.think = hl_rotating;
	//self.nextthink = time + .1;
};

#define SF_BRUSH_ROTATE_INSTANT 	1
#define	SF_PENDULUM_SWING			2
#define SF_PENDULUM_AUTO_RETURN		16
#define	SF_PENDULUM_PASSABLE		32

void() Brush_Think =
{
	local entity oself;
	oself=self;
	self=self.owner;
	oself.think1();
	self=oself;
	dremove(self);
};
void ( entity br_Owner, void() br_Think, float br_Ntime) Brush_Thinkme =
{
#ifdef yay
	local entity brthinker;
	//self.nextthink = br_Ntime;
	//return;
	brthinker = spawn ();
	brthinker.owner = br_Owner;
	brthinker.think = Brush_Think;
	brthinker.think1 = br_Think;
	brthinker.nextthink = br_Ntime;
#endif
};

void () pendulum_stop =
{
	self.angles = self.m_start;
	self.speed = 0;
	self.think = SUB_Null;
	self.avelocity = self.g_vecZero;
};

void () pendulum_swing =
{
	local vector delta;
	local float dt;
	//_bprint(self.classname, " is me classnameeee\n");
	delta =  (self.angles - self.m_center);
	dt = time - self.m_time;	// How much time has passed?
	self.m_time = time;		// Remember the last time called

	if (self.barrel == vlen(self.avelocity))
		if (self.has_tesla == 1)
			self.has_tesla = 0;
		else
			self.has_tesla = 1;
	
	self.barrel = vlen(self.avelocity);
	if ( self.has_tesla == 1 /*vlen(delta) > 0 && self.m_accel > 0*/ )
		self.speed -= self.m_accel * dt;	// Integrate velocity
	else 
		self.speed += self.m_accel * dt;

	if ( self.speed > self.m_maxSpeed )
		self.speed = self.m_maxSpeed;
	else if ( self.speed < -self.m_maxSpeed )
		self.speed = -self.m_maxSpeed;
		
	// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = self.speed * self.movedir;
	//_bprint(ftos(self.speed), " is the speed and ", ftos(self.maxspeed), " is the maxspeed\n");
	

	if ( self.m_damp )
	{
		self.m_dampSpeed -= self.m_damp * self.m_dampSpeed * dt;
		if ( self.m_dampSpeed < 30.0 )
		{
			self.angles = self.m_center;
			self.speed = 0;
			self.think = SUB_Null;
			self.avelocity = self.g_vecZero;
		}
		else if ( self.speed > self.m_dampSpeed )
			self.speed = self.m_dampSpeed;
		else if ( self.speed < -self.m_dampSpeed )
			self.speed = -self.m_dampSpeed;

	}
	
	//_bprint(vtos(self.avelocity) , " is avelocity4\n");
	// Call this again
	Brush_Thinkme( self, self.think, self.ltime + 0.1 );
	//self.nextthink = self.ltime + 0.1;
};

void () pendulum_rope_touch =
{
};

void () pendulum_use =
{
	local vector	delta;
	
	if ( self.speed )		// Pendulum is moving, stop it and auto-return if necessary
	{
		if ( self.spawnflags & #SF_PENDULUM_AUTO_RETURN ) 
		{		
			delta = ( self.angles - self.m_start );

			self.avelocity = self.m_maxSpeed * self.movedir;
			self.think = pendulum_stop;
			Brush_Thinkme( self, self.think, (self.ltime + vlen (delta) / self.m_maxSpeed) );
			//self.nextthink = self.ltime + vlen (delta) / self.m_maxSpeed;
		}
		else
		{
			self.speed = 0;		// Dead stop
			self.think = SUB_Null;
			self.avelocity = self.g_vecZero;
		}
	}
	else
	{
		self.m_time = time;		// Save time to calculate dt
		self.think = pendulum_swing;
		Brush_Thinkme( self, self.think, self.ltime + 0.1 );
		//self.nextthink = self.ltime + 0.1;		// Start the pendulum moving
		self.m_dampSpeed = self.m_maxSpeed;
	}
};

void () func_pendulum =
{
	SetMovedir ();
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;

	self.blocked = rot_crush;
	if (self.spawnflags & 64)
	{
		self.solid = SOLID_BSP;
	}
	else
	{
		self.solid = 4;
		//self.blocked = movewall_blocked;
	}
	setorigin(self, self.origin);
	setmodel(self, self.model);

	self.m_distance = self.distance;	// xav: not sure?
	self.m_damp = self.damp;			// this too
	if ( self.m_distance == 0 )
		return;

	if (self.speed == 0)
		self.speed = 100;

	self.m_accel = (self.speed * self.speed) / (2 * fabs(self.m_distance));	// Calculate constant acceleration from speed and distance
	self.m_maxSpeed = self.speed;
	self.m_start = self.angles;
	self.m_center = self.angles + (self.m_distance * 0.5) * self.movedir;

	self.speed = 0;
	
	if (self.spawnflags & #SF_BRUSH_ROTATE_INSTANT) {
		self.think = pendulum_use;
		self.nextthink = self.ltime + 0.1;
	}
	self.use = pendulum_use;

	if ( self.spawnflags & #SF_PENDULUM_SWING )
	{
		//self.touch = pendulum_rope_touch;
	}
};

/*
func_rot_button
- not the way Half-Life does it, but good 'nuf I hope \
*/
void () func_rot_button_use;
void () func_rot_button_touch;
#define next_use_time	rv_s_h
#define SF_MOMENTARY		1024
void () func_rot_button_reactivate =
{
	self.owner.touch = func_rot_button_touch;
	self.owner.th_die = func_rot_button_use;
	self.owner.hl_use = func_rot_button_use;

	dremove(self);
};

void () hl_rotating_button_toggle =
{
	if (self.building == world) {
		bprint(2, "hl_rotating_button_toggle: no .building\n");
		return;
	}
	self = self.building;
	self.use();
};

void () hl_rotating_button =
{
	local float mvspd, plyr_found, realmvspd, movedoor;
	local entity oself, t_plyr, targ;
	plyr_found = 1;
	oself = self;
	
	realmvspd = 250;
	
	mvspd = 4;
	self.armorvalue += mvspd;
	if (self.armorvalue > self.distance)
	{
		mvspd = mvspd + (self.armorvalue - self.distance);
	}
	
	self = self.owner;
	
	if (self.spawnflags & #SF_MOMENTARY) {
		plyr_found = 0;
		t_plyr = findradius(((self.absmax+self.absmin)*.5), 40);
		while (t_plyr != world)
		{
			if (t_plyr.classname == "player")
			{
				plyr_found = 1;
			}
			t_plyr = t_plyr.chain;
		}
	}
	
	if (!plyr_found) {
		if (self.spawnflags & 32) { // toggle = we dont return
			oself.armorvalue += mvspd * -1;
			mvspd = 0;
		}
		else {
			oself.armorvalue += mvspd * -2;
			if (oself.armorvalue < 0){
				oself.armorvalue = 0;
				mvspd = 0;
			}
			mvspd *= -1;
		}
	}
	
	if (self.spawnflags & 2)
		mvspd = mvspd * -1;
	if (self.has_tesla == 0)
		mvspd = mvspd * -1;
		
	if (self.spawnflags & 64)
		self.pos1_z += mvspd;
	else if (self.spawnflags & 128)
		self.pos1_x += mvspd;
	else 
		self.pos1_y += mvspd;

	//self.angles = self.pos1;
	SUB_CalcAngleMove (self.pos1, realmvspd, SUB_Null);
	if (self.owner) {
		if (mapname == "hldemo3") {			// FIXME: I dislike map hacks. Make this work natively!!
			if (self.owner.angles_y > 260 && self.owner.angles_y < 280)
				Delayed_Timer( "on", 0 );
			//else
			//	Delayed_Timer( "off", 0 );
		}
		if (self.owner.spawnflags & 64)
			self.owner.pos1_z += mvspd;
		else if (self.owner.spawnflags & 128)
			self.owner.pos1_x += mvspd;
		else 
			self.owner.pos1_y += mvspd;
		SUB_CalcAngleMoveEnt (self.owner, self.owner.pos1, realmvspd, SUB_Null);
	}
	
	// move the door that we're connected to in conjunction with our position
	if (self.spawnflags & #SF_MOMENTARY) {
		if (self.enemy != world) {
			targ = find(world, targetname, oself.owner.target);
			while (targ) {
				self = targ;
				movedoor = (oself.armorvalue/oself.distance);
				if (movedoor > 1) {
					movedoor = 1;
				}
				//_bprint(ftos(movedoor)," is movedoor val\n");
				if (self.state == STATE_TOP) {
					SUB_CalcMove (self.pos1 + (self.pos2 * (1 - movedoor)), 999, SUB_Null);		// FIXME: goes instant instead of in tandem with rot_button
					oself.owner.ideal_yaw = (vlen( self.origin - self.pos1 ) / vlen( self.pos2 - self.pos1 ));
				}
				else {
					SUB_CalcMove (self.pos2 * movedoor, 999, SUB_Null);
					oself.owner.ideal_yaw = 1 - (vlen( self.origin - self.pos2 ) / vlen( self.pos1 - self.pos2 ));
				}
					
				if (movedoor >= 1) {
					if (self.state != STATE_TOP)
						self.state = STATE_TOP;
					else
						self.state = STATE_BOTTOM;
				}
				
				targ = find(targ, targetname, oself.owner.target);
			}
		}
	}
	
	self = oself;
	
	//self.armorvalue += mvspd;
	if (self.armorvalue >= self.distance)
	{
		self.owner.hl_use = func_rot_button_use;	// hmm, not sure when this should be deactivated though
		if (self.owner.spawnflags & 32) {
			//bprint(2,"BLAAAAHHH\n");
		}
		else {
			//self.owner.hl_use = func_rot_button_use;
			//self.owner.solid = SOLID_BSP;
			//self.owner.health = 1;
			//self.owner.th_die = func_rot_button_use;
		}

		if (self.owner.spawnflags & #SF_MOMENTARY) {
			self = self.owner;
			//SUB_UseTargets();
			self.touch = func_rot_button_touch;
			//self.th_die = func_rot_button_use;
			self.hl_use = func_rot_button_use;
			self = oself;
		}
		
		if (self.owner.wait > 0)
		{
			self.think = func_rot_button_reactivate;
			self.nextthink = time + self.owner.wait;
		}
		else
			dremove(self);
			
		return;
	}
	
	if (self.owner.spawnflags & #SF_MOMENTARY && self.owner.spawnflags & 32 || self.owner.spawnflags & #SF_MOMENTARY && self.owner.targetname) {
		self.use = hl_rotating_button;
		self.owner.use = hl_rotating_button_toggle;
		self.owner.hl_use = hl_rotating_button_toggle;
		
	}
	else
		self.nextthink = time + .02;
};

void () func_rot_button_use =
{
	local entity targ;

	if (has_master(self))
		return;
	if (self.has_tesla == 0)
		self.has_tesla = 1;
	else
		self.has_tesla = 0;
	newmis = spawn();
	newmis.owner = self;
	newmis.health = self.#next_use_time;
	newmis.distance = self.distance;
	newmis.think = hl_rotating_button;
	newmis.nextthink = time + .1;
	self.building = newmis;
	
	if (self.spawnflags & #SF_MOMENTARY) {		// find momentary door to move..
		targ = find(world, targetname, self.target);
		if (targ == world)
			bprint(2,"WARNING: func_rot_button_use: momentary_rot_button has no momentary_door associated with it.\n");		// should probably be objerror, but I'm too forgiving :x
		else
			self.enemy = targ;
	}
	else
		SUB_UseTargets();
	
	self.th_die = SUB_Null;
	self.takedamage = 0;
	self.hl_use = SUB_Null;
	self.use = SUB_Null;
	self.touch = SUB_Null;
	
	targ = find(world, targetname, self.targetname);		// mainly for Uplink demo to work somewhat properly
	while (targ) {
		if (targ.classname == self.classname && targ != self) {
			self.owner = targ;
		}
		targ = find(targ, targetname, self.targetname);
	}
};

void () func_rot_button_touch =
{
	if (other.classname != "player")
		return;
	if (self.#next_use_time > time && self.#next_use_time != -1)
		return;
		
	if (has_master(self))
		return;
		
		//bprint(2,"blehhh\n");
		
	if (self.wait > 0)
		self.#next_use_time = time + self.wait;
	else
		self.#next_use_time = -1;
		
	self.touch = SUB_Null;
	func_rot_button_use();
};

void () func_rot_button =
{
	self.movetype = 7;
/*	if (self.spawnflags & 1)
	{
		self.solid = 0;
	}
	else*/
	{
		self.solid = 4;
	}
	
	//if (self.spawnflags & 1024)
		self.use = func_rot_button_use;

	if (self.health > 0 || self.spawnflags & 512)		// damage activated
	{
		self.takedamage = 1;
		if (self.health == 0)
			self.health = 1;
	}
	
    self.th_die = func_rot_button_use;
	self.hl_use = func_rot_button_use;
		
	setmodel(self, self.model);
	self.touch = func_rot_button_touch;
	
};

void () momentary_rot_button =
{
	self.spawnflags += #SF_MOMENTARY;
	func_rot_button();
}