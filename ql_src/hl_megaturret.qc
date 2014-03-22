// MegaTF turret
//made by Ambush (as far as I know)

.float rotate_type;

float enemy_yaw1, enemy_vis1, enemy_range1, enemy_infront1;

void() turret_ret2;
void() turret_active;

float () MTurret_FindTarget =
{
	local entity te;
	if (self.show_hostile > time)
		return 0;
	te = find(world, monster_string, "on");
	while (te)
	{
		if (te.health > 0 && visible(te)) {
			self.enemy = te;
			self.show_hostile = time + 1;
			SightSound();
			HuntTarget();
			return 1;
		}
		te = find(te, monster_string, "on");
	}
	return 0;
};

void() beam_touch = 
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
		totaldmg = self.currentammo * 1.25;
		totaldmg = ceil(totaldmg);
		if (other.health <= totaldmg)
		{
			T_Damage(other, self, self.owner, 99999, MOD_HLIFE);
			if (other.health <= 0)
			{
				remove(self);
				return;
			}
		}
		else
		{
			T_Damage(other, self, self.owner, totaldmg, MOD_HLIFE);
		}
	}
	sound(self, 3, "enforcer/enfstop.wav", 1, 1);
	BecomeExplosion();
};

void() beam_generate = 
{
	local entity beamseg;
	beamseg = spawn();
	beamseg.owner = self.owner;
	beamseg.solid = 2;
	setmodel(beamseg, "progs/beam.mdl");
	beamseg.skin = self.owner.team_no - 1;
	setsize(beamseg, '0 0 0', '0 0 0');
	makevectors(self.owner.v_angle);
	if (self.owner.flags & 8)
	{
		self.owner.attack_finished = time + 0.5;
		setorigin(beamseg, self.owner.origin + v_forward * 12 + self.owner.dest2);
		beamseg.velocity = aim(self.owner, 800) * 800;
	}
	else
	{
		if (self.owner.flags & 32)
		{
			setorigin(beamseg, self.owner.origin);
			beamseg.velocity = normalize(self.owner.enemy.origin - self.owner.origin) * 800;
		}
		else
		{
			setorigin(beamseg, self.owner.origin);
			beamseg.velocity = self.owner.movedir * 800;
		}
	}
	beamseg.angles = vectoangles(beamseg.velocity);
	beamseg.speed = 800;
	beamseg.classname = "beam";
	beamseg.movetype = 9;
	beamseg.currentammo = self.currentammo;
	beamseg.touch = beam_touch;
	beamseg.think = SUB_Remove;
	beamseg.nextthink = time + 6;
	sound(self.owner, 1, "enforcer/enfire.wav", 1, 1);
	self.currentammo = self.currentammo / 2;
	if (self.owner.flags & 8 && self.deadflag == 0)
	{
		self.owner.velocity = self.velocity - v_forward * self.currentammo * 2;
	}
	if (self.currentammo < 1)
	{
		remove(self);
	}
	self.nextthink = time + 0.05;
};

float(float pitch) turret_frame = 
{
	return floor(pitch / 5.625);
};

float(float pitch) turret_fireframe = 
{
	return turret_frame(pitch) + 23;
};

float() CheckTurretAttack = 
{
	local vector spot1;
	local vector spot2;
	local entity targ;
	local float chance;
	targ = self.enemy;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline(spot1, spot2, 0, self);
	if (trace_ent != targ)
	{
		return 0;
	}
	if (trace_inopen && trace_inwater)
	{
		return 0;
	}
	if (time < self.attack_finished)
	{
		return 0;
	}
	if (enemy_range1 == 0)
	{
		chance = 0.9;
	}
	else
	{
		if (enemy_range1 == 1)
		{
			chance = 0.6;
		}
		else
		{
			if (enemy_range1 == 2)
			{
				chance = 0.3;
			}
			else
			{
				chance = 0.1;
			}
		}
	}
	if (random() < chance)
	{
		self.th_missile();
		if (self.spawnflags & 8)
		{
			SUB_AttackFinished(1.5 + 2 * random());
		}
		if (self.spawnflags & 16)
		{
			SUB_AttackFinished(1.5 + 3 * random());
		}
		if (self.spawnflags & 32)
		{
			SUB_AttackFinished(1 + 1 * random());
		}
		else
		{
			SUB_AttackFinished(1 + 1.5 * random());
		}
		return 1;
	}
	return 0;
};

void() turret_face = 
{
	local vector tmpvec;
	tmpvec = vectoangles(self.origin - (self.enemy.origin + self.enemy.view_ofs));
	if (tmpvec_x > self.rotate_type)
	{
		if (tmpvec_x > self.rotate_type + 6)
		{
			self.rotate_type = self.rotate_type + 6;
		}
		else
		{
			self.rotate_type = tmpvec_x;
		}
	}
	else
	{
		if (tmpvec_x < self.rotate_type)
		{
			if (tmpvec_x < self.rotate_type - 6)
			{
				self.rotate_type = self.rotate_type - 6;
			}
			else
			{
				self.rotate_type = tmpvec_x;
			}
		}
	}
	self.frame = turret_frame(self.rotate_type);
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw();
};

void() turret_still = [0, turret_still]
{
	self.frame = turret_frame(self.rotate_type);
#ifdef mtf_coop
	if (self.netname == "monster_miniturret")
		FindTarget();
	else
		MTurret_FindTarget ();
#else
	FindTarget();
#endif
};

void() turret_ret1 = [16, turret_ret1]
{
	if (self.frame >= 15)
	{
		turret_ret2();
		return;
	}
	self.frame = self.frame + 1;
	self.nextthink = time + 0.05;
};

void() turret_ret2 = [16, turret_ret3]
{
	self.nextthink = time + 0.2;
	sound(self, 3, "weapons/gunidle1.wav", 1, 1);
};

void() turret_ret3 = [17, turret_ret4]
{
	self.nextthink = time + 0.2;
};

void() turret_ret4 = [18, turret_ret5]
{
	self.nextthink = time + 0.2;
};

void() turret_ret5 = [19, turret_ret6]
{
	self.solid = 0;
	self.nextthink = time + 0.2;
};

void() turret_ret6 = [20, turret_ret7]
{
	self.nextthink = time + 0.2;
};

void() turret_ret7 = [21, turret_ret8]
{
	self.nextthink = time + 0.2;
};

void() turret_ret8 = [22, turret_retracted]
{
	if (!(self.currentammo))
	{
		self.think = SUB_Null;
	}
	self.nextthink = time + 0.05;
};

void() turret_unret1 = [21, turret_unret2]
{
	self.nextthink = time + 0.05;
	sound(self, 3, "weapons/gunidle1.wav", 1, 1);
};

void() turret_unret2 = [20, turret_unret3]
{
	self.nextthink = time + 0.05;
};

void() turret_unret3 = [19, turret_unret4]
{
	self.nextthink = time + 0.05;
};

void() turret_unret4 = [18, turret_unret5]
{
	self.solid = 3;
	setmodel(self, "progs/turret.mdl");
	self.nextthink = time + 0.05;
};

void() turret_unret5 = [17, turret_unret6]
{
	self.nextthink = time + 0.05;
};

void() turret_unret6 = [16, turret_unret7]
{
	self.nextthink = time + 0.05;
};

void() turret_unret7 = [0, turret_unret7]
{
	if (self.frame > turret_frame(self.rotate_type) + 1)
	{
		self.frame = self.frame - 2;
	}
	else
	{
		self.frame = turret_frame(self.rotate_type);
		turret_active();
	}
};

void() turret_retracted = [22, turret_retracted]
{
#ifdef mtf_coop
	if (MTurret_FindTarget())
#else
	if (FindTarget())
#endif
	{
		turret_unret1();
	}
};

void() turret_active = [0, turret_active]
{
	enemy_infront1 = infront(self.enemy);
	enemy_range1 = range(self.enemy);
	enemy_yaw1 = vectoyaw(self.enemy.origin - self.origin);
	self.frame = turret_frame(self.rotate_type);
	enemy_vis1 = visible(self.enemy);
	if (self.enemy.health <= 0 || self.enemy.deadflag != 0 || !enemy_vis1)
	{
		self.enemy = world;
		enemy_vis1 = visible(self.oldenemy);
		if (enemy_vis1 && self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget();
		}
		else
		{
			self.th_stand();
			return;
		}
	}
	self.show_hostile = time + 1;
	enemy_vis1 = visible(self.enemy);
	if (enemy_vis1)
	{
		self.search_time = time + 0.2;
	}
	if (self.search_time < time)
	{
#ifdef mtf_coop
		if (MTurret_FindTarget())
#else
		if (FindTarget())
#endif
		{
			return;
		}
	}
	if (self.attack_state == 4 || self.attack_state == 3)
	{
		ai_run_missile(enemy_yaw1);
		return;
	}
	CheckTurretAttack();
};

void() turret_bullet1 = [0, turret_bullet2]
{
	local vector dir;
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "turret/plasbult.wav", 1, 1);
	self.effects = self.effects | 2;
	dir = self.enemy.origin - self.enemy.velocity * 0.3 * random();
	dir = normalize(dir - self.origin);
	FireBullets(2, dir, '0 0 0', MOD_HLIFE);
};

void() turret_bullet2 = [0, turret_bullet3]
{
	turret_face();
	self.nextthink = time + 0.05;
};

void() turret_bullet3 = [0, turret_bullet4]
{
	local vector dir;
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "turret/plasbult.wav", 1, 1);
	self.effects = self.effects | 2;
	dir = self.enemy.origin - self.enemy.velocity * 0.3 * random();
	dir = normalize(dir - self.origin);
	FireBullets(2, dir, '0 0 0', MOD_HLIFE);
};

void() turret_bullet4 = [0, turret_bullet5]
{
	turret_face();
	self.nextthink = time + 0.05;
};

void() turret_bullet5 = [0, turret_active]
{
	local vector dir;
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "turret/plasbult.wav", 1, 1);
	self.effects = self.effects | 2;
	dir = self.enemy.origin - self.enemy.velocity * 0.3 * random();
	dir = normalize(dir - self.origin);
	FireBullets(2, dir, '0 0 0', MOD_HLIFE);
};

void() turret_laser1 = [0, turret_laser2]
{
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "enforcer/enfire.wav", 1, 1);
	self.effects = self.effects | 2;
	//deathmsg = 44;
	newmis = launch_missile("progs/laser.mdl", self.origin, '600 0 0');
	target_missile(newmis, self.enemy.origin, 1);
};

void() turret_laser2 = [0, turret_laser3]
{
	turret_face();
};

void() turret_laser3 = [0, turret_laser4]
{
	turret_face();
};

void() turret_laser4 = [0, turret_laser5]
{
	turret_face();
};

void() turret_laser5 = [0, turret_active]
{
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "enforcer/enfire.wav", 1, 1);
	self.effects = self.effects | 2;
	//deathmsg = 44;
	newmis = launch_missile("progs/laser.mdl", self.origin, '600 0 0');
	target_missile(newmis, self.enemy.origin, 1);
};

void() turret_rocket1 = [0, turret_active]
{
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	sound(self, 1, "weapons/sgun1.wav", 1, 1);
	self.effects = self.effects | 2;
	//deathmsg = 44;
	newmis = launch_missile("progs/missile.mdl", self.origin, '1000 0 0');
	target_missile(newmis, self.enemy.origin, 1);
	setdmg_missile(newmis, 15, 15);
};

void() turret_beam1 = [0, turret_beam2]
{
	//deathmsg = 44;
	turret_face();
	sound(self, 1, "weapons/railgr1a.wav", 1, 1);
	self.nextthink = time + 0.2;
};

void() turret_beam2 = [0, turret_beam3]
{
	//deathmsg = 44;
	sound(self, 1, "weapons/railgr1a.wav", 1, 1);
	turret_face();
	self.nextthink = time + 0.2;
};

void() turret_beam3 = [0, turret_beam4]
{
	//deathmsg = 44;
	sound(self, 1, "weapons/railgr1a.wav", 1, 1);
	turret_face();
	self.nextthink = time + 0.2;
};

void() turret_beam4 = [0, turret_beam5]
{
	//deathmsg = 44;
	turret_face();
	self.frame = turret_fireframe(self.rotate_type);
	if (self.waterlevel > 1)
	{
		return;
	}
	newmis = spawn();
	newmis.solid = 0;
	newmis.movetype = 5;
	newmis.currentammo = 10;
	setorigin(newmis, self.origin);
	newmis.owner = self;
	newmis.think = beam_generate;
	newmis.nextthink = time + 0.05;
};

void() turret_beam5 = [0, turret_beam6]
{
	turret_face();
};

void() turret_beam6 = [0, turret_beam7]
{
	turret_face();
};

void() turret_beam7 = [0, turret_active]
{
	turret_face();
};

void() turret_fire1 = [0, turret_fire2]
{
	turret_face();
	if (infront(self.enemy))
	{
		self.think = turret_fire2;
	}
	self.nextthink = time + 0.05;
};

void() turret_fire2 = [0, turret_fire3]
{
	turret_face();
	self.nextthink = time + 0.05;
};

void() turret_fire3 = [0, turret_fire4]
{
	turret_face();
	self.nextthink = time + 0.05;
};

void() turret_fire4 = [0, turret_fire4]
{
	//deathmsg = 44;
	turret_face();
	if (self.spawnflags & 8)
	{
		turret_laser1();
	}
	else
	{
		if (self.spawnflags & 16)
		{
			turret_rocket1();
		}
		else
		{
			if (self.spawnflags & 32)
			{
				turret_beam1();
			}
			else
			{
				turret_bullet1();
			}
		}
	}
};

void() turret_die = 
{
	local entity dedtur;
	self.use = SUB_Null;
	self.effects = 0;
	dedtur = spawn();
	dedtur.solid = 0;
	dedtur.movetype = 10;
	dedtur.angles = self.angles;
	dedtur.avelocity = '300 300 200';
	setorigin(dedtur, self.origin);
	setmodel(dedtur, "progs/dedturet.mdl");
	setsize(self, '-10 -10 -3', '10 10 12');
	dedtur.skin = self.skin;
	dedtur.effects = 0;
	ThrowHead("progs/h_turret.mdl", self.health);
};

void(entity attacker, float t_damage) turret_pain = 
{
	if (self.pain_finished > time)
	{
		return;
	}
	self.pain_finished = time + 1;
};

void() turret_use = 
{
	if (self.currentammo)
	{
		self.currentammo = 0;
		if (self.spawnflags & 2 || (self.spawnflags & 4))
		{
			turret_ret1();
		}
		else
		{
			self.think = SUB_Null;
		}
	}
	else
	{
		self.currentammo = 1;
		if (self.spawnflags & 2 || (self.spawnflags & 4))
		{
			turret_unret1();
		}
		else
		{
			turret_still();
		}
	}
};

void() turret_setup = 
{
	local vector endorg;
	traceline(self.origin, self.origin + '0 0 2000', 1, self);
	endorg = trace_endpos;
	endorg_z = endorg_z - 12;
	setorigin(self, endorg);
	if (self.spawnflags & 1)
	{
		if (self.spawnflags & 2 || (self.spawnflags & 4))
		{
			self.frame = 22;
			self.solid = 0;
		}
		else
		{
			self.frame = turret_frame(self.rotate_type);
		}
		self.currentammo = 0;
		self.think = SUB_Null;
	}
	else
	{
		if (self.spawnflags & 2)
		{
			self.solid = 0;
			turret_retracted();
		}
		else
		{
			turret_still();
		}
		self.nextthink = self.nextthink + random() * 0.5;
	}
};

void() monster_turret = 
{
#ifdef mtf_coop_halflife
	if (#HL_MAP)
		if (!self.team_no) {
				self.classname = "monster_miniturret";
				self.team_no = 2;
				self.origin_z -= 30;
			}
#endif
	precache_model("progs/turret.mdl");
	precache_model("progs/h_turret.mdl");
	precache_model("progs/dedturet.mdl");
	if (self.spawnflags & 8)
	{
		precache_model("progs/laser.mdl");
		precache_sound("enforcer/enfire.wav");
		precache_sound("enforcer/enfstop.wav");
	}
	else
	{
		if (self.spawnflags & 16)
		{
			precache_model("progs/missile.mdl");
			precache_sound("weapons/sgun1.wav");
		}
		else
		{
			if (self.spawnflags & 32)
			{
				precache_model("progs/beam.mdl");
				precache_sound("enforcer/enfire.wav");
				precache_sound("enforcer/enfstop.wav");
			}
			else
			{
				precache_sound("turret/plasbult.wav");
			}
		}
	}
	self.solid = 3;
	self.movetype = 4;
	setmodel(self, "progs/turret.mdl");
	setsize(self, '-12 -12 -8', '12 12 12');
	if (self.health < 1)
	{
		self.health = 1500;
	}
	self.max_health = self.health;
	if (self.rotate_type < 0 || self.rotate_type > 90)
	{
		self.rotate_type = 0;
	}
	self.currentammo = 1;
#ifdef mtf_coop_halflife
	if (self.classname == "monster_miniturret") {
		self.netname = "monster_miniturret";
	}
#endif
	self.classname = "bot";
	if (self.spawnflags & 2)
	{
		self.th_stand = turret_ret1;
		self.th_walk = turret_ret1;
	}
	else
	{
		self.th_stand = turret_still;
		self.th_walk = turret_still;
	}
	self.th_run = turret_active;
	self.th_pain = turret_pain;
	self.th_die = turret_die;
	self.th_missile = turret_fire1;
	total_monsters = total_monsters + 1;
	self.takedamage = 2;
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = 30;
	self.view_ofs = '0 0 -0.1';
	self.use = turret_use;
	self.flags = self.flags | 1;
	self.flags = self.flags | 32;
	self.pausetime = 100000000;
	self.nextthink = self.nextthink + random() * 0.5;
	self.think = turret_setup;
};
 