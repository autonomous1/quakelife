//#define NEW_WATER
void () func_water_use =
{
	if (self.has_tesla == 1) {
		SUB_CalcMove(self.pos1, self.speed, SUB_Null);
		self.has_tesla = 0;
	}
	else {
		SUB_CalcMove(self.pos2, self.speed, SUB_Null);
		self.has_tesla = 1;
	}
};

#ifdef NEW_WATER
void() liquid_touch =
{
	local float test;
	local float /*r,g,b,i,*/c;
	
	if (!(other.flags & FL_CLIENT)) {
		
		// Handle some special cases (always set think1 as death function!)
		if (other.classname == "drip") {
			setorigin(other, other.origin + '0 0 6');
			self = other;
			self.think1();
			return;
		}
		else if (other.classname == "spark") {
			self = other;
			self.think1();
			return;
		}
		else if (other.classname == "particle" && other.owner.spawnflags & KILLINFWATER) {	
			self = other;
			self.think1();
			return;
		}
		
	// Trick the C code into playing the splash sound... (even though I find it annoying as hell)
		
		// These movetypes don't splash
		if (other.movetype == MOVETYPE_NONE ||
			other.movetype == MOVETYPE_PUSH	||
			other.movetype == MOVETYPE_NOCLIP)// MOVETYPE_WALK is always FL_CLIENT so don't worry about it
			return;
		
		// Wait for the engine to assign CONTENT_EMPTY before changing watertype (just spawned)
		if (other.fwatershifttime < time && other.watertype) {					
			other.watertype = self.watertype;
			other.waterlevel = 1;
		}
			
		// C code will go nuts with the splash sound if we don't time out while in func_water
		other.fwatershifttime = time + 0.1;	
		return;
	}
	
	// Don't let water sweep ayway someone on a ladder (not if totally underwater though)
	if (other.laddertime > time) return;
	
	// Test Feet (if feet are below maxs and above mins, we're in)
	test = other.origin_z + other.mins_z + 1;
	if (test <= self.absmax_z && test >= self.absmin_z) {
		
		other.watertype = self.watertype;
		other.waterlevel = 1;
		
		// Test Torso
		test = other.origin_z + (other.mins_z + other.maxs_z) * 0.5;
		if (test <= self.absmax_z) {
			other.waterlevel = 2;
			other.zerogtime = time+0.05;// remove gravity in PreThink
		}
		
		// Test Eyes
		test = other.origin_z + other.view_ofs_z;
		if (test <= self.absmax_z) {
			other.waterlevel = 3;
			
			// Do the color shift
			stuffcmd(other, "v_cshift ");
			stuffcmd(other, self.cshift);
			stuffcmd(other, "\n");
	
			// Tell PreThink to clear the cshift when the player is out
			other.fwatershifttime = time+frametime;
			other.fwatershift = TRUE;
		}
		
		// Add drag and/or current
		if (self.spawnflags & EASEUNDERCURRENT) c = 4-other.waterlevel; else c = other.waterlevel;	
		if (self.drag) other.velocity = other.velocity + self.velocity*(self.drag*frametime)*c;
		if (self.mangle != '0 0 0') other.velocity = other.velocity + self.mangle*frametime*(c/3);
		
	}
	
	// xavior movement hax 
	local vector pvec;

	if (other.classname != "player")
		return;
	
	makevectors (other.v_angle);
	pvec = v_forward;
	pvec = (pvec * 250);
	if (other.button2)		// jump off the ladder
		other.velocity = pvec;
	else
		other.velocity_z = pvec_z;
};

void () func_water = {

if (mapname == "openfire" || mapname == "tfc_openfire") 
   dremove(self);
   
   self.solid = 1.000;
   self.movetype = 0.000;
   //setorigin (self,self.origin);
   setmodel (self,self.model);
  // setorigin (self,((self.absmax+self.absmin)*.5));
  setorigin(self, self.origin);
  
	SetMovedir ();
	if (!self.lip)
		self.lip = 8;
	if (!self.speed)
		self.speed = 100;
		
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
	
	if (self.spawnflags & 1) { // start moved
		setorigin(self, self.pos2);
		self.has_tesla = 1;
	}
	
	self.use = func_water_use;
	
	if (self.watertype<-5 || self.watertype>-3)
		self.watertype = CONTENT_WATER;
		
	if (self.cshift == string_null) {
		if (self.watertype == CONTENT_WATER)
			self.cshift = "130 80 50 128";
		else if (self.watertype == CONTENT_SLIME)
			self.cshift = "0 25 5 150";
		else if (self.watertype == CONTENT_LAVA)
			self.cshift = "255 80 0 150";
	}
	
	// Cap drag force
	if (self.drag > 100) self.drag = 100;
	if (self.drag < 0) self.drag = 0;
	
	if (self.mangle != '0 0 0')
		self.mangle = self.mangle*50;
	
	//if (!self.speed) self.speed = 10;
	//if (!self.speed2) self.speed2 = self.speed;
	
   if (#HL_MAP) {
	self.touch = liquid_touch; // better swim function is required lol
   }


	HalfLife_DoRender();
};

#else
void () liquid_touch =
{
	local vector pvec;

	if (other.classname != "player")
		return;
	
	makevectors (other.v_angle);
	pvec = v_forward;
	pvec = (pvec * 250);
	if (other.button2)		// jump off the ladder
		other.velocity = pvec;
	else
		other.velocity_z = pvec_z;
};

void () func_water = {

if (mapname == "openfire" || mapname == "tfc_openfire") 
   dremove(self);
   
   self.solid = 1.000;
   self.movetype = 0.000;
   //setorigin (self,self.origin);
   setmodel (self,self.model);
  // setorigin (self,((self.absmax+self.absmin)*.5));
  setorigin(self, self.origin);
  
	SetMovedir ();
	if (!self.lip)
		self.lip = 8;
	if (!self.speed)
		self.speed = 100;
		
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
	
	if (self.spawnflags & 1) { // start moved
		setorigin(self, self.pos2);
		self.has_tesla = 1;
	}
	
	self.use = func_water_use;
	
   if (#HL_MAP) {
	self.touch = liquid_touch; // better swim function is required lol
   }
   else
	self.touch = SplashTouch;

	HalfLife_DoRender();
};
#endif