// XavioR: Added the killable chthon from the end of bbelief and other mods..
/*
==============================================================================

BOSS-ONE - kinda messy, may be some redundancies left...                                                                                                                                        KillKillableBoss Chthon!  by Dave Weiden

==============================================================================
*/
$cd /raid/quake/id1/models/boss1
$origin 0 0 -15
$base base
$skin skin
$scale 5

$frame rise1 rise2 rise3 rise4 rise5 rise6 rise7 rise8 rise9 rise10
$frame rise11 rise12 rise13 rise14 rise15 rise16 rise17 

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15
$frame walk16 walk17 walk18 walk19 walk20 walk21 walk22
$frame walk23 walk24 walk25 walk26 walk27 walk28 walk29 walk30 walk31

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15
$frame attack16 attack17 attack18 attack19 attack20 attack21 attack22
$frame attack23

$frame shocka1 shocka2 shocka3 shocka4 shocka5 shocka6 shocka7 shocka8
$frame shocka9 shocka10 

$frame shockb1 shockb2 shockb3 shockb4 shockb5 shockb6

$frame shockc1 shockc2 shockc3 shockc4 shockc5 shockc6 shockc7 shockc8 
$frame shockc9 shockc10

void() killable_boss_idle1;

void() killable_boss_missile1;

float() KillableBossFindTarget;     //Forward

float() KillableBossFindTargetIdle;   //when he returns to sleep

void(vector p) killable_boss_missile; 

void () Boss_MissileTouch =
{
	local float damg;

	if ((other == self.owner))
	{
		return;
	}
	if ((pointcontents (self.origin) == CONTENT_SKY))
	{
		remove (self);
		return;
	}
	damg = (100 + (random () * 20));
	T_RadiusDamage (self, self.owner, 120, 120, world, MOD_CHTHON);
	self.origin = (self.origin - (8 * normalize (self.velocity)));
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion ();
};

void() killable_boss_face =
{
	if (coop)
	{
	if (self.enemy.health <= 0 || random() < 0.01)
	{
		self.enemy = find(self.enemy, classname, "player");
		if (!self.enemy)
			self.enemy = find(self.enemy, classname, "player");
	} 
	}
	ai_face();
};

void() killable_boss_face2 =    // for idle KillableBoss
{
	if(self.enemy != world)
		killable_boss_missile1();
	else
		KillableBossFindTargetIdle();  //fixes animation problems
};

void() killable_boss_rise1       =[      $rise1, killable_boss_rise2 ] {
sound (self, CHAN_WEAPON, "boss1/out1.wav", 1, ATTN_NORM);
};
void() killable_boss_rise2       =[      $rise2, killable_boss_rise3 ] {
sound (self, CHAN_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);
};
void() killable_boss_rise3       =[      $rise3, killable_boss_rise4 ] {};
void() killable_boss_rise4       =[      $rise4, killable_boss_rise5 ] {};
void() killable_boss_rise5       =[      $rise5, killable_boss_rise6 ] {};
void() killable_boss_rise6       =[      $rise6, killable_boss_rise7 ] {};
void() killable_boss_rise7       =[      $rise7, killable_boss_rise8 ] {};
void() killable_boss_rise8       =[      $rise8, killable_boss_rise9 ] {};
void() killable_boss_rise9       =[      $rise9, killable_boss_rise10 ] {};
void() killable_boss_rise10      =[      $rise10, killable_boss_rise11 ] {};
void() killable_boss_rise11      =[      $rise11, killable_boss_rise12 ] {};
void() killable_boss_rise12      =[      $rise12, killable_boss_rise13 ] {};
void() killable_boss_rise13      =[      $rise13, killable_boss_rise14 ] {};
void() killable_boss_rise14      =[      $rise14, killable_boss_rise15 ] {};
void() killable_boss_rise15      =[      $rise15, killable_boss_rise16 ] {};
void() killable_boss_rise16      =[      $rise16, killable_boss_rise17 ] {};
void() killable_boss_rise17      =[      $rise17, killable_boss_missile1 ] {};

void() killable_boss_idle1       =[      $walk1, killable_boss_idle2 ]
{
// look for other players
};
void() killable_boss_idle2       =[      $walk2, killable_boss_idle3 ] {killable_boss_face();};
void() killable_boss_idle3       =[      $walk3, killable_boss_idle4 ] {killable_boss_face2();};
void() killable_boss_idle4       =[      $walk4, killable_boss_idle5 ] {killable_boss_face();};
void() killable_boss_idle5       =[      $walk5, killable_boss_idle6 ] {killable_boss_face2();};
void() killable_boss_idle6       =[      $walk6, killable_boss_idle7 ] {killable_boss_face();};
void() killable_boss_idle7       =[      $walk7, killable_boss_idle8 ] {killable_boss_face2();};
void() killable_boss_idle8       =[      $walk8, killable_boss_idle9 ] {killable_boss_face();};
void() killable_boss_idle9       =[      $walk9, killable_boss_idle10 ] {killable_boss_face2();};
void() killable_boss_idle10      =[      $walk10, killable_boss_idle11 ] {killable_boss_face();};
void() killable_boss_idle11      =[      $walk11, killable_boss_idle12 ] {killable_boss_face2();};
void() killable_boss_idle12      =[      $walk12, killable_boss_idle13 ] {killable_boss_face();};
void() killable_boss_idle13      =[      $walk13, killable_boss_idle14 ] {killable_boss_face2();};
void() killable_boss_idle14      =[      $walk14, killable_boss_idle15 ] {killable_boss_face();};
void() killable_boss_idle15      =[      $walk15, killable_boss_idle16 ] {killable_boss_face2();};
void() killable_boss_idle16      =[      $walk16, killable_boss_idle17 ] {killable_boss_face();};
void() killable_boss_idle17      =[      $walk17, killable_boss_idle18 ] {killable_boss_face2();};
void() killable_boss_idle18      =[      $walk18, killable_boss_idle19 ] {killable_boss_face();};
void() killable_boss_idle19      =[      $walk19, killable_boss_idle20 ] {killable_boss_face2();};
void() killable_boss_idle20      =[      $walk20, killable_boss_idle21 ] {killable_boss_face();};
void() killable_boss_idle21      =[      $walk21, killable_boss_idle22 ] {killable_boss_face2();};
void() killable_boss_idle22      =[      $walk22, killable_boss_idle23 ] {killable_boss_face();};
void() killable_boss_idle23      =[      $walk23, killable_boss_idle24 ] {killable_boss_face2();};
void() killable_boss_idle24      =[      $walk24, killable_boss_idle25 ] {killable_boss_face();};
void() killable_boss_idle25      =[      $walk25, killable_boss_idle26 ] {killable_boss_face2();};
void() killable_boss_idle26      =[      $walk26, killable_boss_idle27 ] {killable_boss_face();};
void() killable_boss_idle27      =[      $walk27, killable_boss_idle28 ] {killable_boss_face2();};
void() killable_boss_idle28      =[      $walk28, killable_boss_idle29 ] {killable_boss_face();};
void() killable_boss_idle29      =[      $walk29, killable_boss_idle30 ] {killable_boss_face2();};
void() killable_boss_idle30      =[      $walk30, killable_boss_idle31 ] {killable_boss_face();};
void() killable_boss_idle31      =[      $walk31, killable_boss_idle1 ] {killable_boss_face2();};

void() killable_boss_missile1    =[      $attack1, killable_boss_missile2 ] {killable_boss_face();};
void() killable_boss_missile2    =[      $attack2, killable_boss_missile3 ] {killable_boss_face();};
void() killable_boss_missile3    =[      $attack3, killable_boss_missile4 ] {killable_boss_face();};
void() killable_boss_missile4    =[      $attack4, killable_boss_missile5 ] {killable_boss_face();};
void() killable_boss_missile5    =[      $attack5, killable_boss_missile6 ] {killable_boss_face();};
void() killable_boss_missile6    =[      $attack6, killable_boss_missile7 ] {killable_boss_face();};
void() killable_boss_missile7    =[      $attack7, killable_boss_missile8 ] {killable_boss_face();};
void() killable_boss_missile8    =[      $attack8, killable_boss_missile9 ] {killable_boss_face();};
void() killable_boss_missile9    =[      $attack9, killable_boss_missile10 ] {killable_boss_missile('100 100 200');};
void() killable_boss_missile10   =[      $attack10, killable_boss_missile11 ] {killable_boss_face();};
void() killable_boss_missile11   =[      $attack11, killable_boss_missile12 ] {killable_boss_face();};
void() killable_boss_missile12   =[      $attack12, killable_boss_missile13 ] {killable_boss_face();};
void() killable_boss_missile13   =[      $attack13, killable_boss_missile14 ] {killable_boss_face();};
void() killable_boss_missile14   =[      $attack14, killable_boss_missile15 ] {killable_boss_face();};
void() killable_boss_missile15   =[      $attack15, killable_boss_missile16 ] {killable_boss_face();};
void() killable_boss_missile16   =[      $attack16, killable_boss_missile17 ] {killable_boss_face();};
void() killable_boss_missile17   =[      $attack17, killable_boss_missile18 ] {killable_boss_face();};
void() killable_boss_missile18   =[      $attack18, killable_boss_missile19 ] {killable_boss_face();};
void() killable_boss_missile19   =[      $attack19, killable_boss_missile20 ] {killable_boss_face();};
void() killable_boss_missile20   =[      $attack20, killable_boss_missile21 ] {killable_boss_missile('100 -100 200');};
void() killable_boss_missile21   =[      $attack21, killable_boss_missile22 ] {killable_boss_face();};
void() killable_boss_missile22   =[      $attack22, killable_boss_missile23 ] {killable_boss_face();};
void() killable_boss_missile23   =[      $attack23, killable_boss_missile1 ] {killable_boss_face();};

void() killable_boss_shocka1 =[  $shocka1, killable_boss_shocka2 ] {};
void() killable_boss_shocka2 =[  $shocka2, killable_boss_shocka3 ] {};
void() killable_boss_shocka3 =[  $shocka3, killable_boss_shocka4 ] {};
void() killable_boss_shocka4 =[  $shocka4, killable_boss_shocka5 ] {};
void() killable_boss_shocka5 =[  $shocka5, killable_boss_shocka6 ] {};
void() killable_boss_shocka6 =[  $shocka6, killable_boss_shocka7 ] {};
void() killable_boss_shocka7 =[  $shocka7, killable_boss_shocka8 ] {};
void() killable_boss_shocka8 =[  $shocka8, killable_boss_shocka9 ] {};
void() killable_boss_shocka9 =[  $shocka9, killable_boss_shocka10 ] {};
void() killable_boss_shocka10 =[ $shocka10, killable_boss_missile1 ] {};

void() killable_boss_shockb1 =[  $shockb1, killable_boss_shockb2 ] {};
void() killable_boss_shockb2 =[  $shockb2, killable_boss_shockb3 ] {};
void() killable_boss_shockb3 =[  $shockb3, killable_boss_shockb4 ] {};
void() killable_boss_shockb4 =[  $shockb4, killable_boss_shockb5 ] {};
void() killable_boss_shockb5 =[  $shockb5, killable_boss_shockb6 ] {};
void() killable_boss_shockb6 =[  $shockb6, killable_boss_shockb7 ] {};
void() killable_boss_shockb7 =[  $shockb1, killable_boss_shockb8 ] {};
void() killable_boss_shockb8 =[  $shockb2, killable_boss_shockb9 ] {};
void() killable_boss_shockb9 =[  $shockb3, killable_boss_shockb10 ] {};
void() killable_boss_shockb10 =[ $shockb4, killable_boss_missile1 ] {};

void() killable_boss_shockc1 =[  $shockc1, killable_boss_shockc2 ] {};
void() killable_boss_shockc2 =[  $shockc2, killable_boss_shockc3 ] {};
void() killable_boss_shockc3 =[  $shockc3, killable_boss_shockc4 ] {};
void() killable_boss_shockc4 =[  $shockc4, killable_boss_shockc5 ] {};
void() killable_boss_shockc5 =[  $shockc5, killable_boss_shockc6 ] {};
void() killable_boss_shockc6 =[  $shockc6, killable_boss_shockc7 ] {};
void() killable_boss_shockc7 =[  $shockc7, killable_boss_shockc8 ] {};
void() killable_boss_shockc8 =[  $shockc8, killable_boss_shockc9 ] {};
void() killable_boss_shockc9 =[  $shockc9, killable_boss_shockc10 ] {};
void() killable_boss_shockc10 =[ $shockc10, killable_boss_death1 ] {};

void() killable_boss_flinch1 =[ $shockc1, killable_boss_flinch2 ] {};
void() killable_boss_flinch2 =[ $shockc2, killable_boss_flinch3 ] {};
void() killable_boss_flinch3 =[ $shockc3, killable_boss_flinch4 ] {};
void() killable_boss_flinch4 =[ $shockc4, killable_boss_missile1 ] {};

void() killable_boss_death1 = [$death1, killable_boss_death2] {
sound (self, CHAN_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
};
void() killable_boss_death2 = [$death2, killable_boss_death3] {};
void() killable_boss_death3 = [$death3, killable_boss_death4] {};
void() killable_boss_death4 = [$death4, killable_boss_death5] {};
void() killable_boss_death5 = [$death5, killable_boss_death6] {};
void() killable_boss_death6 = [$death6, killable_boss_death7] {};
void() killable_boss_death7 = [$death7, killable_boss_death8] {};
void() killable_boss_death8 = [$death8, killable_boss_death9] {};
void() killable_boss_death9 = [$death9, killable_boss_death10]
{
	sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
};

void() killable_boss_death10 = [$death9, killable_boss_death10]
{
	killed_monsters = killed_monsters + 1;
	WriteByte (MSG_ALL, SVC_KILLEDMONSTER); // FIXME: reliable broadcast
	SUB_UseTargets ();
	remove (self);
};

void(vector p) killable_boss_missile =
{
	local   vector  offang;
	local   vector  org, vec, d;
	local   float   t;

	offang = vectoangles (self.enemy.origin - self.origin); 
	makevectors (offang);

	org = self.origin + p_x*v_forward + p_y*v_right + p_z*'0 0 1';
	
// lead the player on hard mode
	
	if (skill > 1)
	{
		t = vlen(self.enemy.origin - org) / 600;
		vec = self.enemy.velocity;
		vec_z = 0;
		d = self.enemy.origin + t * vec;                
	}
	else
	{
		d = self.enemy.origin;
	}
	
	vec = normalize (d - org);

	launch_spike (org, vec);
	setmodel (newmis, "progs/lavaball.mdl");
	newmis.avelocity = '200 100 600';
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);               
	newmis.velocity = vec*600;
	newmis.touch = Boss_MissileTouch; // rocket explosion
	sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);

// check for dead enemy
	if (self.enemy.health <= 0)
		KillableBossFindTarget ();   //Look Around!
};

void () killable_boss_use = 
{
	if (useType > 0) {
		bprint(2,"silly usetype cant be 2 for meh!\n");
		return;
	}
	boss_death1();
};

void() killable_boss_awake =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	self.takedamage = DAMAGE_AIM;
	
	setmodel (self, "progs/boss.mdl");
	setsize (self, '-128 -128 -24', '128 128 256');
	
	if (skill == 0)
		self.health = 2000;
	else
		self.health = 6000;

	self.enemy = activator;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.yaw_speed = 20;
	self.use = killable_boss_use;
	killable_boss_rise1 ();
};

void(entity attacker)     killable_boss_pain =
{
	local float     r;

	hldprint(2,"I'm in pain!\n");
// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;
	
	r = random();
	
	if ((r < 0.15)&&(attacker.classname !="monster_killable_boss"))
	{
		sound (self, CHAN_VOICE, "boss1/death.wav", 1, ATTN_NORM);
		self.pain_finished = time + 5;
		ThrowGib ("progs/gib1.mdl", -180);
		ThrowGib ("progs/gib2.mdl", -180);
		ThrowGib ("progs/gib3.mdl", -180);
		killable_boss_flinch1 ();
		self.enemy = attacker;
	}
	else
	{
		self.enemy = attacker;  //Pissed off at who Hurt him
		if (self.enemy.classname == "monster_killable_boss") //Don't get mad at self
			KillableBossFindTarget();  //Leave nothing within radius alive!
		if (self.enemy == world) killable_boss_missile1();
	}
};

void() head_gib =
{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		local float c/*=1*/;  
		c=1;             
		barrel_explode ();
		while (c<6)
		{
		ThrowGib ("progs/gib1.mdl", -120);
		ThrowGib ("progs/gib2.mdl", -120);
		ThrowGib ("progs/gib3.mdl", -120);
		c=c+1;
		}
		remove (self);         
};

void () SUB_Gib =
{
	local vector x;
	local vector y;
	local vector v;
	local float r_num;

	if ((other.team_no == self.team_no))
	{
		return;
	}
	r_num = random ();
	if ((r_num < 0.6))
	{
		x = '1 0 0';
		y = '0 1 0';
		v = ((x * (50 - (random () * 100))) + (y * (50 - (random () * 100))));
		r_num = random ();
		SpawnMeatSpray (self.origin, v);
	}
	else
	{
		if ((r_num >= 0.6))
		{
			ThrowGib ("progs/gib1.mdl", self.health);
		}
		else
		{
			ThrowGib ("progs/gib3.mdl", self.health);
		}
	}
};

void() killable_boss_gib =
{
		local float c;
		c=1;
		
		sound (self, CHAN_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_boss.mdl", -200);
		// reduce while if edicts error occurs
		while (c<15)
		{
		ThrowGib ("progs/gib1.mdl", -200);
		ThrowGib ("progs/gib2.mdl", -200);
		ThrowGib ("progs/gib3.mdl", -200);
		c=c+1;
		}
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER); // FIXME: reliable broadcast
		SUB_UseTargets ();

	self.health=185;
	setsize (self, '-10 -10 -24', '10 10 24');
	self.th_stand = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_run = SUB_Null;
	self.th_pain = SUB_Gib;
	self.th_die = head_gib;
	self.th_melee = SUB_Null;
	self.solid = SOLID_SLIDEBOX;
	self.th_missile = SUB_Null;
	self.takedamage= DAMAGE_AIM; 

};

void() killable_boss_die =
{
	local float c;
	c=1;

// check for gib
	if (self.health < -70)
	{
		killable_boss_gib ();
		return;
	}

// regular death
	while (c<3)
	{
	ThrowGib ("progs/gib1.mdl", -180);
	ThrowGib ("progs/gib2.mdl", -180);
	ThrowGib ("progs/gib3.mdl", -180);
	c=c+1;
	}
	killable_boss_death1 ();

};

float() KillableBossFindTarget =   //"Borrowed" from BPlayer Bot
{
	local entity head, selected;
	local float dist;
	dist = 1000;    // awareness radius of boss 
	selected = world;

	head = findradius(self.origin, 1000);
	while(head)
	{
	    /*    if (((deathmatch) && (!(head.flags & FL_NOTARGET) && ((head.flags & FL_CLIENT) || (head.flags & FL_MONSTER)))) ||
		   ((!deathmatch) && (!(head.flags & FL_NOTARGET) && (head.flags & FL_MONSTER))))
		if (((teamplay) &&  (head.team != self.team)) || (!teamplay))
		if ((head.health > 1) && (head != self))
		if (visible(head))
		if (trace_plane_dist < dist) */
		if ((head.health > 0) && (head !=self))
		   {
			selected = head;
			dist = trace_plane_dist;
		   }
		head = head.chain;
	}
	self.enemy = selected;
		
	if (self.enemy == world)
		killable_boss_idle1();   //Just hang out
	else
	{
		killable_boss_face();    //Look at your opponent
		return TRUE;
	}
};

float() KillableBossFindTargetIdle =   
{
	local entity head, selected;
	local float dist;
	dist = 1000;    // awareness radius of boss 
	selected = world;

	head = findradius(self.origin, 1000);
	while(head)
	{
		if ((head.health > 0) && (head !=self))
		   {
			selected = head;
			dist = trace_plane_dist;
		   }
		head = head.chain;
	}
	self.enemy = selected;
		
	if (self.enemy == world)
		return FALSE;
	else
	{
		killable_boss_face();    //Look at your opponent
		return TRUE;
	}
};


//=============================================================
// killable_boss_stand - boss stands in place until target acquired
//=============================================================
//"Borrowed" from BPlayer Bot
void() killable_boss_stand =
{
	if (KillableBossFindTarget ())
		return;
      
	self.th_stand ();
};


/*QUAKED monster_boss (1 0 0) (-128 -128 -24) (128 128 256)
*/
void() monster_killable_boss =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/boss.mdl");
	precache_model ("progs/h_boss.mdl");
	precache_model ("progs/lavaball.mdl");

	precache_sound ("player/udeath.wav");
	precache_sound ("weapons/rocket1i.wav");
	precache_sound ("boss1/out1.wav");
	precache_sound ("boss1/sight1.wav");
	precache_sound ("misc/power.wav");
	precache_sound ("boss1/throw.wav");
	precache_sound ("boss1/pain.wav");
	precache_sound ("boss1/death.wav");

	total_monsters = total_monsters + 1;

	self.th_die = killable_boss_die;
	self.use = killable_boss_awake;
	self.th_pain = killable_boss_pain;
	self.th_stand = killable_boss_stand;
};



