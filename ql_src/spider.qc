void () spid_leap1;
void () spider_pain;
void () spider_poison;
.float is_poisoned, pcolor, poison_time;
float poison_globaltime;
.string deathtype;

void () spid_stand = [ 0, spid_stand ]
{
	ai_stand ();
};
void () spid_walk2;

void () spid_walk1 = [ 0, spid_walk2 ]
{
	if ((random () < 0.2))
	{
		sound (self, FL_SWIM, "spider/sidle.wav", TRUE, FL_SWIM);
	}
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk3;

void () spid_walk2 = [ 1, spid_walk3 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk4;

void () spid_walk3 = [ 2, spid_walk4 ]
{
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk5;

void () spid_walk4 = [ 3, spid_walk5 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk6;

void () spid_walk5 = [ 4, spid_walk6 ]
{
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk7;

void () spid_walk6 = [ 5, spid_walk7 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk8;

void () spid_walk7 = [ 6, spid_walk8 ]
{
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk9;

void () spid_walk8 = [ 7, spid_walk9 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_walk (MOVETYPE_STEP);
};
void () spid_walk10;

void () spid_walk9 = [ 8, spid_walk10 ]
{
	ai_walk (MOVETYPE_STEP);
};

void () spid_walk10 = [ 9, spid_walk1 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_walk (MOVETYPE_STEP);
};
void () spid_run2;

void () spid_run1 = [ 0, spid_run2 ]
{
	if ((random () < 0.2))
	{
		sound (self, FL_SWIM, "spider/sidle.wav", TRUE, FL_SWIM);
	}
	ai_run (12);
};
void () spid_run3;

void () spid_run2 = [ 2, spid_run3 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_run (12);
};
void () spid_run4;

void () spid_run3 = [ 4, spid_run4 ]
{
	ai_run (12);
};
void () spid_run5;

void () spid_run4 = [ 6, spid_run5 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_run (12);
};
void () spid_run6;

void () spid_run5 = [ 8, spid_run6 ]
{
	ai_run (12);
};
void () spid_run7;

void () spid_run6 = [ 0, spid_run7 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_run (12);
};
void () spid_run8;

void () spid_run7 = [ 2, spid_run8 ]
{
	ai_run (12);
};
void () spid_run9;

void () spid_run8 = [ 4, spid_run9 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_run (12);
};
void () spid_run10;

void () spid_run9 = [ 6, spid_run10 ]
{
	ai_run (12);
};

void () spid_run10 = [ 8, spid_run1 ]
{
	sound (self, FL_SWIM, "spider/swalk.wav", TRUE, FL_SWIM);
	ai_run (12);
};
void () spid_melee2;

void () spid_melee1 = [ 0, spid_melee2 ]
{
	sound (self, FL_SWIM, "spider/shit.wav", TRUE, TRUE);
	ai_charge (FL_INWATER);
};
void () spid_melee3;

void () spid_melee2 = [ 2, spid_melee3 ]
{
	ai_charge (FL_INWATER);
};
void () spid_melee4;

void () spid_melee3 = [ 4, spid_melee4 ]
{
	ai_charge (FL_INWATER);
};
void () spid_melee5;

void () spid_melee4 = [ 6, spid_melee5 ]
{
	ai_charge (FL_INWATER);
};
void () spid_melee6;

void () spid_melee5 = [ 8, spid_melee6 ]
{
	ai_melee (MOD_HLIFE);
	if ((random () < 0.3))
	{
		if (((self.enemy.classname == "player") && !(self.enemy.flags & FL_GODMODE)))
		{
			if ((vlen ((self.origin - self.enemy.origin)) < 100))
			{
				spider_poison ();
			}
		}
	}
};
void () spid_melee7;

void () spid_melee6 = [ 0, spid_melee7 ]
{
	ai_charge (12);
};
void () spid_melee8;

void () spid_melee7 = [ 2, spid_melee8 ]
{
	ai_charge (12);
};
void () spid_melee9;

void () spid_melee8 = [ 4, spid_melee9 ]
{
	ai_charge (12);
};
void () spid_melee10;

void () spid_melee9 = [ 6, spid_melee10 ]
{
	ai_charge (12);
};

void () spid_melee10 = [ 8, spid_run1 ]
{
	ai_charge (12);
};
void () spid_pain2;

void () spid_pain1 = [ 20, spid_pain2 ]
{
};
void () spid_pain3;

void () spid_pain2 = [ 21, spid_pain3 ]
{
};
void () spid_pain4;

void () spid_pain3 = [ 22, spid_pain4 ]
{
};
void () spid_pain5;

void () spid_pain4 = [ 23, spid_pain5 ]
{
};
void () spid_pain6;

void () spid_pain5 = [ 24, spid_pain6 ]
{
};
void () spid_pain7;

void () spid_pain6 = [ 25, spid_pain7 ]
{
};
void () spid_pain8;

void () spid_pain7 = [ 26, spid_pain8 ]
{
};
void () spid_pain9;

void () spid_pain8 = [ 27, spid_pain9 ]
{
};
void () spid_pain10;

void () spid_pain9 = [ 28, spid_pain10 ]
{
};
void () spid_pain11;

void () spid_pain10 = [ 29, spid_pain11 ]
{
};

void () spid_pain11 = [ 30, spid_run1 ]
{
};
void () spid_death3;

void () spid_death1 = [ 10, spid_death3 ]
{
};

void () spid_death2 = [ 10, spid_death3 ]
{
};
void () spid_death4;

void () spid_death3 = [ 11, spid_death4 ]
{
};
void () spid_death5;

void () spid_death4 = [ 12, spid_death5 ]
{
};
void () spid_death6;

void () spid_death5 = [ 13, spid_death6 ]
{
};
void () spid_death7;

void () spid_death6 = [ 14, spid_death7 ]
{
};
void () spid_death8;

void () spid_death7 = [ 15, spid_death8 ]
{
};
void () spid_death9;

void () spid_death8 = [ 16, spid_death9 ]
{
};
void () spid_death10;

void () spid_death9 = [ 17, spid_death10 ]
{
};
void () spid_death11;

void () spid_death10 = [ 18, spid_death11 ]
{
	//Become_Corpse ();
};

void () spid_death11 = [ 19, spid_death11 ]
{
	if (!checkclient ())
	{
		remove (self);
	}
};

void () spider_pain =
{
	if ((self.pain_finished > time))
	{
		return;
	}
	sound (self, FL_SWIM, "spider/spain.wav", TRUE, TRUE);
	self.velocity_x = (-50 - (50 * random ()));
	self.velocity_y = FALSE;
	self.velocity_z = (150 + (150 * random ()));
	self.flags = (self.flags - (self.flags & FL_ONGROUND));
	spid_pain1 ();
	self.pain_finished = (time + MOVETYPE_WALK);
};

void () spider_die =
{
	if ((self.health < -90))
	{
		sound (self, FL_SWIM, "player/udeath.wav", TRUE, TRUE);
		ThrowHead ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}
	sound (self, FL_SWIM, "spider/sdeath.wav", TRUE, TRUE);
	self.movetype = MOVETYPE_BOUNCE;
	self.velocity_x = (-50 + (100 * random ()));
	self.velocity_y = (-50 + (100 * random ()));
	self.velocity_z = (300 + (300 * random ()));
	self.avelocity_x = (-20 + (40 * random ()));
	self.avelocity_y = (-200 + (400 * random ()));
	self.avelocity_z = FALSE;
	if ((self.flags & FL_ONGROUND))
	{
		self.flags = (self.flags - (self.flags & FL_ONGROUND));
	}
	spid_death1 ();
	self.solid = FALSE;
};

float () CheckSpiderJump =
{
	local vector dist;
	local float d;

	if ((random () < 0.4))
	{
		return (TRUE);
	}
	if (((self.origin_z + self.mins_z) > ((self.enemy.origin_z + self.enemy.mins_z) + (0.75 * self.enemy.size_z))))
	{
		return (FALSE);
	}
	if (((self.origin_z + self.maxs_z) < ((self.enemy.origin_z + self.enemy.mins_z) + (0.25 * self.enemy.size_z))))
	{
		return (FALSE);
	}
	dist = self.enemy.origin - self.origin;
	dist_z = FALSE;
	d = vlen (dist);
	if ((d < 100))
	{
		return (FALSE);
	}
	if ((d > 200))
	{
		if ((random () < 0.9))
		{
			return (FALSE);
		}
	}
	return (TRUE);
};

void () Spider_JumpTouch =
{
	local float ldmg;

	if ((self.health <= FALSE))
	{
		return;
	}
	if (other.takedamage)
	{
		if ((vlen (self.velocity) > 300))
		{
			sound (self, FL_SWIM, "spider/sattack2.wav", TRUE, TRUE);
			ldmg = MOVETYPE_BOUNCE + (MOVETYPE_BOUNCE * random ());
			T_Damage (other, self, self, ldmg, MOD_HLIFE);
		}
	}
	if (!checkbottom (self))
	{
		if ((self.flags & FL_ONGROUND))
		{
			//self.touch = monster_touch;
			self.think = spid_leap1;
			self.nextthink = (time + 0.1);
		}
		return;
	}
	//self.touch = monster_touch;
	self.think = spid_run1;
	self.nextthink = (time + 0.1);
};

void () spid_leap1 = [ 10, spid_leap2 ]
{
//	local void() spid_leap2;
	local vector dir;
	local float dist;

	if ((self.health <= FALSE))
	{
		self.touch = SUB_Null;
		self.think = spid_death1;
		return;
	}
	ai_face ();
	self.touch = Spider_JumpTouch;
	makevectors (self.angles);
	self.origin_z = (self.origin_z + TRUE);
	if ((self.enemy.origin_z > (self.origin_z + 40)))
	{
		infront (self.enemy);
		if ((infront (self.enemy) || (self.waterlevel == TRUE)))
		{
			dir = normalize ((self.enemy.origin - self.origin));
			dist = vlen ((self.enemy.origin - self.origin));
			self.velocity = (dir * dist);
		}
		else
		{
			self.velocity = (v_forward * 150);
		}
		dist = self.enemy.origin_z - self.origin_z;
		dist = dist - 237;
		self.velocity_z = (714 + dist);
	}
	else
	{
		if ((self.enemy.origin_z < (self.origin_z - 40)))
		{
			self.velocity = (v_forward * 150);
		}
		else
		{
			self.velocity = (v_forward * 600);
		}
		traceline ((self.origin - '0 0 16'), ((self.origin - '0 0 16') + (v_forward * 150)), TRUE, self);
		if ((trace_fraction < TRUE))
		{
			self.velocity = (v_forward * 110);
			self.velocity_z = (250 * (random () + TRUE));
		}
		else
		{
			self.velocity_z = 250;
		}
	}
	if ((self.flags & FL_ONGROUND))
	{
		self.flags = (self.flags - FL_ONGROUND);
	}
};
void () spid_leap3;

void () spid_leap2 = [ 11, spid_leap3 ]
{
};

void () spid_leap3 = [ 12, spid_run1 ]
{
	self.nextthink = (time + MOVETYPE_WALK);
};

void () spider_attack =
{
	if (CheckSpiderJump ())
	{
		if ((random () < 0.5))
		{
			sound (self, FL_SWIM, "spider/sattack.wav", TRUE, TRUE);
			spid_leap1 ();
		}
	}
	return;
};

void () poisondamage =
{
	if ((self.is_poisoned != FALSE))
	{
		if ((self.pcolor <= FL_NOTARGET))
		{
			self.pcolor = (self.pcolor + TRUE);
		}
		else
		{
			self.pcolor = FL_NOTARGET;
		}
		stuffcmd (self, "v_idlescale ");
		stuffcmd (self, ftos (floor (((self.pcolor - self.health) * 0.15))));
		stuffcmd (self, "\n");
		stuffcmd (self, "v_cshift 255 0 0 ");
		stuffcmd (self, ftos ((self.pcolor - self.health)));
		stuffcmd (self, "\n");
		if ((time >= self.poison_time))
		{
			if ((random () < 0.5))
			{
				T_Damage (self, world, world, TRUE, MOD_HLIFE);
			}
			else
			{
				T_Damage (self, world, world, FL_SWIM, MOD_HLIFE);
			}
			self.deathtype = "poisoned";
			self.poison_time = (time + MOVETYPE_WALK);
		}
	}
};

void () spider_poison =
{
	spawn_touchblood (FL_SWIM);
	T_Damage (self.enemy, self, self.owner, MOVETYPE_WALK, MOD_HLIFE);
	self.enemy.is_poisoned = TRUE;
	if ((self.enemy.health <= FALSE))
	{
		self.enemy.deathtype = "poison";
	}
	poison_globaltime = poison_globaltime + MOVETYPE_FLY;
};

void () spider_sight =
{
	sound (self, CHAN_VOICE, "spider/ssight.wav", START_OFF, ATTN_NORM);
};

void () monster_spider1 =
{
	self.solid = MOVETYPE_WALK;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/spider.mdl");
	setsize(self, VEC_HULL_MIN, '16 16 18');
	//setsize (self, VEC_HULL2_MIN, '32 32 5');
	self.health = 100;
	self.th_stand = spid_stand;
	self.th_walk = spid_walk1;
	self.th_run = spid_run1;
	self.th_die = spider_die;
	self.th_pain = spider_pain;
	self.th_missile = spider_attack;
	self.th_melee = spid_melee1;
	self.th_sight = spider_sight;
	walkmonster_start ();
};

void () monster_spider =
{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model2 ("progs/spider.mdl");
	precache_model2 ("progs/w_spike.mdl");
	precache_sound ("spider/swalk.wav");
	precache_sound ("spider/sattack.wav");
	precache_sound ("spider/sattack2.wav");
	precache_sound ("spider/shit.wav");
	precache_sound ("spider/sdeath.wav");
	precache_sound ("spider/sidle.wav");
	precache_sound ("spider/spain.wav");
	precache_sound ("spider/ssight.wav");

	self.netname = "poison spider";

	//self.monsterweight = #MWEIGHT_NORMAL;
	//self.monsterflags = #MFLAG_HASWEAPON | #MFLAG_HUMANOID;

	//self.#monsterflag = #STRFLAG_MONSTER;

//	self.#npc_origangle = self.angles;
	//self.#npc_spawndelay = 30;
	//self.#npc_spawnfunc = monster_spider1;
	//COOP_SetLives ();

	monster_spider1 ();
};
