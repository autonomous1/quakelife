// pushable stuff (code taken from nehahra+megatf coop
// physics pushables by Urre

float (entity Top, entity Bottom ) IsOnTopOf =
{
  if (Top.absmin_z < Bottom.absmax_z - 3) {
    return 0;
    }
  if (Top.absmin_z > Bottom.absmax_z + 2) {
    return 0;
    }
  if (Top.absmin_y > Bottom.absmax_y) {
    return 0;
    }
  if (Top.absmax_y < Bottom.absmin_y) {
    return 0;
    }
  if (Top.absmin_x > Bottom.absmax_x) {
    return 0;
    }
  if (Top.absmax_x < Bottom.absmin_x) {
    return 0;
    }
  return 1;
}

void () player_push2 =
{
	local float yaw;
	local vector mvec;

	if ((other.classname != "player"))
	{
		return;
	}

	if (IsOnTopOf(other, self))
		return;
	
    if (self.flags & FL_ONGROUND) {
      self.flags = self.flags - FL_ONGROUND;
      }
	
	yaw = other.angles_y* 3.14159265358979323846 *2 / 360;
		
	mvec_x = cos(yaw)*80;
	mvec_y = sin(yaw)*80;

	self.velocity = mvec;
	/*
	if ((walkmove (other.angles_y, 2) == FALSE))
	{
		self.velocity_x = (other.velocity_x + (4 * random ()));
		self.velocity_y = (other.velocity_y + (4 * random ()));
	}
	*/
};

void () func_pushable_think =
{

	if (self.buoyancy) {
		if (pointcontents((self.absmax+self.absmin)*.5) == CONTENT_WATER/* || pointcontents((self.absmax+self.absmin)*.5) == -1*/)
		{
			self.movetype = MOVETYPE_BOUNCE;
			self.velocity_z = 100;
		}
		else
			self.movetype = MOVETYPE_STEP;
		//bprint(2,"floatinnnggg\n");
	}
	self.nextthink = time + .1;
};

void () func_pushable_use_think =
{
	if (self.enemy != world) {
		if (time > self.has_tesla) {
			self.enemy = world;
			self.touch = player_push2;
		}
		else {
			walkmove (self.enemy.angles_y, -10);
		}
	}
	self.nextthink = time;
};

void () func_pushable_hluse =
{
	if (time < self.has_tesla) {
		self.has_tesla = 0;
		return;
	}
	self.has_tesla = time + 2;
	self.enemy = activator;
	self.touch = SUB_Null;
	self.think = func_pushable_use_think;
	self.nextthink = time;
};

#ifdef PHYSICS
// Half-Life pushables made into twig-objects
void () func_pushable =
{
	setmodel (self, self.model);
	setorigin (self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.angles = '0 0 0';

	self.relative_org = (self.maxs + self.mins)*0.5;
	self.relative_forward = '1 0 0';
	self.relative_left = '0 1 0';
	self.relative_up = '0 0 1';

	// the following lines should be defined in the map object, not in qc
	self.netname = "hl-pushable";
	self.physobj_stiction = 50;
	self.physobj_friction = 0.08;
	self.physobj_friction_water = 0.01;
	self.physobj_bounce = 1;
	self.physobj_buoyancy = 0.3;
	self.physobj_mass = 15;

	self.physobj_mass = max(1, self.physobj_mass);
	self.mdl = self.model; // used by the spawning code

	self.enemy = Dynamic_SubModelObject(self, self, self);
	makevectors(self.angles);
	Phys_ObjectCreate(self.enemy, self.relative_org, v_forward, v_right * -1, v_up, '0 0 0', 0);
	self.model = ""; // invisible, could be removed instead if you like
};
// End Half-Life pushables
#else
void () func_pushable =
{
	//precache_sound ("wall/push.wav");			// ADDME: New or dynamic push sound
	if (self.spawnflags & 128) {	// breakable
		func_breakable();
	}
	
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.classname = "pushwall";
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, self.model);
	setorigin (self, self.origin);
	setsize (self, self.mins, self.maxs);


	
	// super: neherha intended for you to be able to push the barrels.
	// the other push function was messed up (pushed parallel to your direction) 
	self.touch = player_push2;

	if (mapname == "c1a2")
		if (self.model == "*29")
			self.origin_z -= 13;
			
	if (#HL_MAP) {
		if (self.buoyancy > 0)
		{
		self.origin_z += 10;
			self.movetype = MOVETYPE_BOUNCE;
			self.think = func_pushable_think;
			self.nextthink = time + .5;
		}
	}

	self.hl_use = func_pushable_hluse;
};
#endif