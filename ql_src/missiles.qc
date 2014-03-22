void() M_Laser_Touch;
void() M_Grenade_Explode;
void() M_Grenade_Touch;
void() M_Missile_Touch;
void() M_Spike_Touch;
void() M_Arrow_Point;
void() M_Arrow_Touch;

entity(string mismodel, vector misorigin, vector misvelocity) launch_missile = 
{
	local entity missile;
	missile = spawn();
	missile.owner = self;
	missile.solid = 2;
	setmodel(missile, mismodel);
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, misorigin);
	missile.velocity = misvelocity;
	missile.avelocity = '0 0 0';
	missile.angles = vectoangles(missile.velocity);
	if (mismodel == "progs/laser.mdl")
	{
		missile.classname = "laser";
		missile.movetype = 5;
		missile.effects = 8;
		missile.nextthink = time + 5;
		missile.attack_finished = missile.nextthink;
		missile.think = SUB_Remove;
		missile.touch = M_Laser_Touch;
		missile.ammo_shells = 15;
		missile.ammo_nails = 0;
	}
	else
	{
		if (mismodel == "progs/grenade.mdl")
		{
			missile.classname = "grenade";
			missile.movetype = 10;
			missile.avelocity = '300 300 300';
			missile.think = M_Grenade_Explode;
			missile.touch = M_Grenade_Touch;
			missile.ammo_shells = 100;
			missile.ammo_nails = 0;
			missile.gravity = self.gravity;
			missile.nextthink = time + 2 + 1 / missile.gravity;
			if (missile.nextthink < time + 1)
			{
				missile.nextthink = time + 1;
			}
			if (missile.nextthink > time + 15)
			{
				missile.nextthink = time + 15;
			}
			missile.attack_finished = missile.nextthink;
		}
		else
		{
			if (mismodel == "progs/missile.mdl")
			{
				missile.classname = "missile";
				missile.movetype = 5;
				missile.effects = 8;
				missile.nextthink = time + 5;
				missile.attack_finished = missile.nextthink;
				missile.think = SUB_Remove;
				missile.touch = M_Missile_Touch;
				missile.ammo_shells = 100;
				missile.ammo_nails = 0;
			}
			else
			{
				if (mismodel == "progs/lavaball.mdl")
				{
					missile.classname = "lavaball";
					missile.solid = 1;
					missile.movetype = 6;
					missile.avelocity = '300 300 300';
					missile.think = M_Grenade_Explode;
					missile.touch = M_Grenade_Explode;
					missile.ammo_shells = 100;
					missile.ammo_nails = 0;
					missile.gravity = self.gravity;
					missile.effects = 8;
					missile.nextthink = time + 2 + 1 / missile.gravity;
					if (missile.nextthink < time + 1)
					{
						missile.nextthink = time + 1;
					}
					if (missile.nextthink > time + 15)
					{
						missile.nextthink = time + 15;
					}
					missile.attack_finished = missile.nextthink;
				}
				else
				{
					if (mismodel == "progs/spike.mdl" || mismodel == "progs/s_spike.mdl")
					{
						missile.classname = "spike";
						missile.movetype = 5;
						setsize(missile, '0 0 0', '0 0 0');
						missile.nextthink = time + 6;
						missile.attack_finished = missile.nextthink;
						missile.think = SUB_Remove;
						missile.touch = M_Spike_Touch;
						if (mismodel == "progs/s_spike.mdl")
						{
							missile.ammo_shells = 18;
						}
						else
						{
							missile.ammo_shells = 9;
						}
						missile.ammo_nails = 0;
					}
					else
					{
						if (mismodel == "progs/k_spike.mdl" || mismodel == "progs/w_spike.mdl")
						{
							if (mismodel == "progs/w_spike.mdl")
							{
								missile.classname = "wizspike";
							}
							else
							{
								missile.classname = "knightspike";
							}
							missile.movetype = 5;
							setsize(missile, '0 0 0', '0 0 0');
							missile.nextthink = time + 6;
							missile.attack_finished = missile.nextthink;
							missile.think = SUB_Remove;
							missile.touch = M_Spike_Touch;
							missile.ammo_shells = 9;
							missile.ammo_nails = 0;
						}
						else
						{
							if (mismodel == "progs/arrow.mdl")
							{
								missile.classname = "arrow";
								missile.movetype = 6;
								setsize(missile, '0 0 0', '0 0 0');
								missile.nextthink = time + 0.05;
								missile.attack_finished = time + 5;
								missile.gravity = self.gravity;
								missile.think = M_Arrow_Point;
								missile.touch = M_Arrow_Touch;
								missile.ammo_shells = 15;
								missile.ammo_nails = 5;
							}
						}
					}
				}
			}
		}
	}
	return missile;
};

void(entity missile, float basedamage, float randdamage) setdmg_missile = 
{
	missile.ammo_shells = basedamage;
	missile.ammo_nails = randdamage;
};
// pablo. f u decompiler! luckily it's never called :)
/*
//void(entity missile, float misnextthink, <function> misthink, <function> mistouch, float basedamage, float randdamage) setup_missile = 
{
	missile.nextthink = time + misnextthink;
	missile.think = misthink;
	missile.touch = mistouch;
	missile.ammo_shells = basedamage;
	missile.ammo_nails = randdamage;
};*/

void(entity missile, vector mistarget, float targeting) target_missile = 
{
	local vector misvelocity;
	misvelocity = missile.velocity;
	if (targeting == 1)
	{
		missile.velocity = normalize(mistarget - missile.origin);
		missile.velocity = missile.velocity * misvelocity_x;
	}
	else
	{
		if (targeting == 2)
		{
			missile.velocity = normalize(mistarget - self.origin);
			missile.velocity = missile.velocity * misvelocity_x;
			missile.velocity_z = misvelocity_z;
		}
		else
		{
			if (targeting == 3)
			{
				missile.velocity = normalize(mistarget + '0 0 16' - missile.origin);
				missile.angles = vectoangles(missile.velocity);
				makevectors(missile.angles);
				missile.velocity = missile.velocity * misvelocity_x + v_up * misvelocity_z;
			}
			else
			{
				if (targeting == 4)
				{
					missile.velocity = normalize(mistarget - missile.origin);
					missile.velocity = missile.velocity * vlen(misvelocity);
				}
				else
				{
					if (targeting == 5)
					{
						missile.velocity = mistarget - missile.origin;
						missile.angles = vectoangles(missile.velocity);
						makevectors(missile.angles);
						missile.velocity = mistarget + v_right * misvelocity_y + v_up * misvelocity_z;
						missile.velocity = normalize(missile.velocity - missile.origin);
						missile.velocity = missile.velocity * misvelocity_x;
					}
				}
			}
		}
	}
	missile.angles = vectoangles(missile.velocity);
};

void() M_Grenade_Explode = 
{
	local float totaldmg;
	totaldmg = self.ammo_shells + random() * self.ammo_nails;
	T_RadiusDamage(self, self.owner, totaldmg, totaldmg, world, MOD_HLIFE);
	BecomeExplosion();
};

void() M_Grenade_Touch = 
{
	if (other == self.owner)
	{
		return;
	}
	if (other.takedamage == 2)
	{
		M_Grenade_Explode();
		return;
	}
	sound(self, 1, "weapons/bounce.wav", 1, 1);
	if (self.velocity == '0 0 0')
	{
		self.avelocity = '0 0 0';
	}
};

void() M_Laser_Touch = 
{
	local float totaldmg;
	local vector org;
	if (other == self.owner)
	{
		return;
	}
	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}
	totaldmg = self.ammo_shells + random() * self.ammo_nails;
	if (self.ammo_shells + self.ammo_nails == 0)
	{
		totaldmg = 15;
	}
	org = self.origin - 8 * normalize(self.velocity);
	if (other.health)
	{
		T_Damage(other, self, self.owner, totaldmg, MOD_HLIFE);
	}
	else
	{
		sound(self, 1, "enforcer/enfstop.wav", 1, 3);
	}
	remove(self);
};

void() M_Missile_Touch = 
{
	local float totaldmg;
	if (other == self.owner)
	{
		return;
	}
	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}
	totaldmg = self.ammo_shells + random() * self.ammo_nails;
	if (other.health)
	{
		if (self.owner.classname == "monster_shalrath")
		{
			if (other.classname == "monster_zombie")
			{
				T_Damage(other, self, self, 110, MOD_HLIFE);
			}
			else
			{
				if (other.classname == "monster_axzombie")
				{
					T_Damage(other, self, self.owner, 200, MOD_HLIFE);
				}
			}
		}
		else
		{
			if (other.classname == "monster_shambler")
			{
				T_Damage(other, self, self.owner, totaldmg * 0.5 + 10, MOD_HLIFE);
			}
			else
			{
				T_Damage(other, self, self.owner, totaldmg + 20, MOD_HLIFE);
			}
		}
	}
	else
	{
		if (self.classname == "pulse")
		{
			sound(self, 2, "enforcer/enfstop.wav", 1, 3);
			remove(self);
			return;
		}
	}
	if (self.owner.classname == "monster_shalrath")
	{
		T_RadiusDamage(self, self.owner, totaldmg, totaldmg, world, MOD_HLIFE);
	}
	else
	{
		T_RadiusDamage(self, self.owner, totaldmg, totaldmg, other, MOD_HLIFE);
	}
	sound(self, 1, "weapons/r_exp3.wav", 1, 1);
	self.origin = self.origin - 8 * normalize(self.velocity);
	sound(self, 1, "weapons/r_exp3.wav", 1, 1);
	BecomeExplosion();
};

void() M_Spike_Touch = 
{
	local float totaldmg;
	if (other == self.owner)
	{
		return;
	}
	if (other.solid == 1)
	{
		return;
	}
	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		totaldmg = self.ammo_shells + random() * self.ammo_nails;
		T_Damage(other, self, self.owner, totaldmg, MOD_HLIFE);
		remove(self);
		return;
	}
	if (self.classname == "dspike" && random() < 0.33)
	{
		remove(self);
		return;
	}
	remove(self);
};

void() M_Arrow_Point = 
{
	self.nextthink = time + 0.05;
	self.angles = vectoangles(self.velocity);
};

void() M_Arrow_Touch = 
{
	local float totaldmg;
	if (other == self.owner)
	{
		return;
	}
	if (other.solid == 1)
	{
		return;
	}
	if (pointcontents(self.origin) == -6)
	{
		remove(self);
		return;
	}
	if (other.takedamage)
	{
		sound(other, 4, "weapons/arrowhit.wav", 1, 1);
		totaldmg = self.ammo_shells + random() * self.ammo_nails;
		T_Damage(other, self, self.owner, totaldmg, MOD_HLIFE);
		remove(self);
		return;
	}
	self.nextthink = time + 1 + random() * 1;
	self.think = SUB_Remove;
};

