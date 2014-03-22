// Tanks, and related entities (controllable and whatnot)

void () func_mortar_field_use =
{
	local vector orgplace, randv;
	local entity xtarg, ytarg;
	local float i;
	
	if (self.m_fControl == 1)	{	// fixed point
		orgplace_x = activator.origin_x;
		orgplace_y = activator.origin_y;
	}
	else if (self.m_fControl == 2)	{	// table controlled
		xtarg = find( world, targetname, self.m_iszXController );
		if (xtarg == world)
			bprint( 2, "func_mortar_field: .m_iszXController does not target anything\n" );
		else {
			orgplace_x = self.mins_x + ((self.size_x*self.size_x)/self.size_x) * xtarg.ideal_yaw;
		}	
		ytarg = find( world, targetname, self.m_iszYController );
		if (ytarg == world)
			bprint( 2, "func_mortar_field: .m_iszYController does not target anything\n" );
		else {
			orgplace_y = self.mins_y + ((self.size_y*self.size_y)/self.size_y)*ytarg.ideal_yaw;
		}	
	}
	else {
		// random spread
		orgplace_x = self.mins_x + random()*(self.maxs_x-self.mins_x);
		orgplace_y = self.mins_y + random()*(self.maxs_y-self.mins_y);
		orgplace_z = self.maxs_z;
	}

	makevectors(self.angles);
	while (i < self.m_iCount) {
		randv_x = random()*self.m_flSpread;
		randv_y = random()*self.m_flSpread;
		PRJ_FireProjectile(self, 
			"progs/missile.mdl", 
			orgplace + randv + '0 0 -10'*100, 
			v_forward + '0 0 -50' * 10000,
			PE_EXPLOSION, 
			100+random()*20, 
			MOD_HLIFE, 
			5);
		PRJ_SetRadiusDamage(120, 160, MOD_ROCKETRADIUS);
		
		i++;
	}
};

void () func_mortar_field =
{
	//InitTrigger();
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.use = func_mortar_field_use;
	if (!self.m_iCount)
		self.m_iCount = 4;
};



float (entity to_ent, vector from_me) tank_visible =
{
	local vector bot_org;
	local vector dest_org;

	bot_org = from_me;
	dest_org = to_ent.origin;
	//dest_org = _p_7805/*.origin/* + _p_7805.view_ofs*/;
	traceline (bot_org, dest_org, 1, self);
//	botprint( 2, "Tracing for vis..\n" );

	if (trace_fraction < 1)
		return ( 0 );

	return ( 1 );
};

void () mortar_hl_use =
{
	self.enemy = activator;
	bprint(2,"you're the dog now, man!\n");
};

void(float shotcount, vector dir, vector spread, INTEGER mod) Tank_FireBullets =
{
	local   vector direction;
	local   vector  src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;//self.barrel;
	src_z += 25;
	//src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction, mod);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

void() mortar_face =
{
	local vector t_Dest, t_Destx, dir;
	local float fireme;
	fireme = 0;
	
	if (!(self.spawnflags & 32))
	{
		if (self.enemy.health <= 0 /*|| !visible(self.enemy)*/)
		{
			self.enemy = find(self.enemy, classname, "player");
			if (!self.enemy)
				self.enemy = find(self.enemy, classname, "player");
		} 
	}

	if (self.spawnflags & 32) {
	
		if (vlen(self.enemy.origin - self.origin) > 70 && self.enemy.classname == "player") {
			self.enemy = world;
			bprint(2,"enemy left vicinity of tank thing\n");
		}
		if (self.enemy.classname == "player") {
			if (self.enemy.button0)	{		// player is pressing fire, so we fire
				fireme = #TRUE;
			}
			
			t_Dest = self.enemy.angles;
			t_Dest_x *= -1;
		}
		else {
		
		}
	}
	else {
		if (random() < .03)
			fireme = #TRUE;

		t_Dest = vectoangles((self.enemy.origin + self.enemy.view_ofs) - self.origin);
		t_Destx = vectoangles(self.origin - (self.enemy.origin + self.enemy.view_ofs));
		t_Dest_x = t_Destx_x;			
	}


	if (t_Dest == self.angles) {
		self.nextthink = self.ltime + .1;
		return;
	}

	if (!self.spawnflags & 32)	// fix
	{
		if (self.yawtolerance) {
			if ( t_Dest_y > (self.orig_angles_y + (self.yawtolerance*4.5)) || t_Dest_y < (self.orig_angles_y - (self.yawtolerance*4.5)) ) {
				self.nextthink = self.ltime + .1;
				return;
			}
		}
		if (self.pitchtolerance) {
			if ( t_Dest_x > self.pitchtolerance*2.5 && t_Dest_x < (360 - self.pitchtolerance*2.5) ) {
				self.nextthink = self.ltime + .1;
				return;
			}
		}
	}


	if (fireme) {
		if (self.has_tesla < time) {
			makevectors(self.angles);
			if (self.mtf_items & 1)	// fire bullets
			{
				dir = aim (self, 100000);
				muzzleflash();
				//TE_tarexplosion(self.origin + v_forward*self.barrel);
				Tank_FireBullets (1, dir, '0.04 0.04 0', MOD_HLIFE);
			}
			else {
				self.has_tesla = time + self.firerate;
				PRJ_FireProjectile(self, 
					"progs/missile.mdl", 
					self.origin + v_forward*self.barrel, 
					aim(self, 1000) * 10000,
					PE_EXPLOSION, 
					100+random()*20, 
					MOD_HLIFE, 
					5);
				PRJ_SetRadiusDamage(120, 160, MOD_ROCKETRADIUS);
			}
		}
	}
	
	
	SUB_CalcAngleMove (t_Dest, 40, mortar_face);
};

void () func_tankmortardie =
{
	dremove(self);
};

void () func_tankmortar =
{
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	
	if (self.spawnflags & 32)		// player usable
	{
	}
	
	self.use = func_tankmortardie;
	self.hl_use = mortar_hl_use;
	self.orig_angles = self.angles;
	self.think = mortar_face;
	self.nextthink = self.ltime + .1;
	//mortar_face();
	
	
};

void () func_tankrocket =
{
	func_tankmortar();
//	InitTrigger();
//	self.use = func_tank_use;
};

void () func_tank =
{
	self.mtf_items = 1;
	func_tankmortar();
};
