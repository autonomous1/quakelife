//Nihilanth replacement (shubbeh!)
// Basically a flying shub that has 4 "stages"

void () shubmover_think;
void () shub_moveme;
void () Nihilanth_Thrownewdir;

void() nihilanth_idle1        =[      $old1,  nihilanth_idle2       ] {};
void() nihilanth_idle2        =[      $old2,  nihilanth_idle3       ] {};
void() nihilanth_idle3        =[      $old3,  nihilanth_idle4       ] {};
void() nihilanth_idle4        =[      $old4,  nihilanth_idle5       ] {};
void() nihilanth_idle5        =[      $old5,  nihilanth_idle6       ] {};
void() nihilanth_idle6        =[      $old6,  nihilanth_idle7       ] {};
void() nihilanth_idle7        =[      $old7,  nihilanth_idle8       ] {};
void() nihilanth_idle8        =[      $old8,  nihilanth_idle9       ] {};
void() nihilanth_idle9        =[      $old9,  nihilanth_idle10      ] {};
void() nihilanth_idle10       =[      $old10, nihilanth_idle11      ] {};
void() nihilanth_idle11       =[      $old11, nihilanth_idle12      ] {};
void() nihilanth_idle12       =[      $old12, nihilanth_idle13      ] {};
void() nihilanth_idle13       =[      $old13, nihilanth_idle14      ] {};
void() nihilanth_idle14       =[      $old14, nihilanth_idle15      ] {};
void() nihilanth_idle15       =[      $old15, nihilanth_idle16      ] {};
void() nihilanth_idle16       =[      $old16, nihilanth_idle17      ] {};
void() nihilanth_idle17       =[      $old17, nihilanth_idle18      ] {
Nihilanth_Thrownewdir();		// Move shub in a random direction
};
void() nihilanth_idle18       =[      $old18, nihilanth_idle19      ] {};
void() nihilanth_idle19       =[      $old19, nihilanth_idle20      ] {};
void() nihilanth_idle20       =[      $old20, nihilanth_idle21      ] {};
void() nihilanth_idle21       =[      $old21, nihilanth_idle22      ] {};
void() nihilanth_idle22       =[      $old22, nihilanth_idle23      ] {};
void() nihilanth_idle23       =[      $old23, nihilanth_idle24      ] {};
void() nihilanth_idle24       =[      $old24, nihilanth_idle25      ] {};
void() nihilanth_idle25       =[      $old25, nihilanth_idle26      ] {};
void() nihilanth_idle26       =[      $old26, nihilanth_idle27      ] {};
void() nihilanth_idle27       =[      $old27, nihilanth_idle28      ] {};
void() nihilanth_idle28       =[      $old28, nihilanth_idle29      ] {};
void() nihilanth_idle29       =[      $old29, nihilanth_idle30      ] {};
void() nihilanth_idle30       =[      $old30, nihilanth_idle31      ] {};
void() nihilanth_idle31       =[      $old31, nihilanth_idle32      ] {};
void() nihilanth_idle32       =[      $old32, nihilanth_idle33      ] {};
void() nihilanth_idle33       =[      $old33, nihilanth_idle34      ] {};
void() nihilanth_idle34       =[      $old34, nihilanth_idle35      ] {};
void() nihilanth_idle35       =[      $old35, nihilanth_idle36      ] {};
void() nihilanth_idle36       =[      $old36, nihilanth_idle37      ] {};
void() nihilanth_idle37       =[      $old37, nihilanth_idle38      ] {};
void() nihilanth_idle38       =[      $old38, nihilanth_idle39      ] {};
void() nihilanth_idle39       =[      $old39, nihilanth_idle40      ] {};
void() nihilanth_idle40       =[      $old40, nihilanth_idle41      ] {};
void() nihilanth_idle41       =[      $old41, nihilanth_idle42      ] {};
void() nihilanth_idle42       =[      $old42, nihilanth_idle43      ] {};
void() nihilanth_idle43       =[      $old43, nihilanth_idle44      ] {};
void() nihilanth_idle44       =[      $old44, nihilanth_idle45      ] {};
void() nihilanth_idle45       =[      $old45, nihilanth_idle46      ] {};
void() nihilanth_idle46       =[      $old46, nihilanth_idle1       ] {};

void () Nihilanth_Throwspawns =
{
/*
	local float i, wt;
	local entity oself, nmon;
	oself = self;

	wt = 4;
	while (i < 300) {
		nmon = spawn ();
		nmon.origin = (self.origin + '0 0 244');
		nmon.velocity_z = 3000;
		nmon.velocity_x = (-100 + (random () * 2000));
		nmon.velocity_y = (-100 + (random () * 2000));
		nmon.flags = 256;
		nmon.solid = 1;
		nmon.movetype = MOVETYPE_BOUNCE;
		nmon.monstertype = monster_barney;
		nmon.monstercount = 1;
		setsize (nmon, '-16 -16 0', '16 16 56');
		setmodel(nmon, "");
		nmon.has_tesla = wt;
		self = nmon;
		monstermaker();
		self = oself;
		wt += 4;
		i++;
	}
*/
};


void () Nihilanth_Thrownewdir =
{
	local entity oself, ndir;
	local float arnd, brnd;
	oself = self;
	arnd = random();
	if (arnd > .5)
		arnd = -1;
	else
		arnd = 1;

		
	if (shub.building == world) {
		ndir = spawn ();
		ndir.owner = self;
		setsize (ndir, self.mins, self.maxs);
		ndir.size = self.size;
		ndir.origin = (self.origin + '0 0 244');
		ndir.velocity_z = (-100*arnd + (random () * 2000));//3000;
		ndir.velocity_x = (-100*arnd + (random () * 2000));
		ndir.velocity_y = (-100*arnd + (random () * 2000));
		ndir.solid = SOLID_BBOX;
		ndir.movetype = MOVETYPE_BOUNCE;
		//setsize (ndir, '-16 -16 0', '16 16 56');
		setmodel(ndir, "");
		ndir.think = shub_moveme;
		ndir.nextthink = time + 1.5;
		self.building = ndir;
		brnd = random();
		if (brnd > .7) {
			ndir.velocity = '0 0 0';
			ndir.origin = self.orig_origin;
		}
	}
};

// :D
void(vector tdest, float tspeed, void() func) SHUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	//self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.03)
		traveltime = 0.03;
	
// set nextthink to trigger a think when dest is reached
	//self.nextthink = time + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

void () shub_moveme =
{
	local entity oself;
	local float mvspd;
	
	if (self.owner.health > 2000)
		mvspd = 350;
	else if (self.owner.health > 1000)
		mvspd = 450;
	else if (self.owner.health > 0)
		mvspd = 600;
	
	if (!self.owner || self.owner.health <= 0) {
		dremove(self);
		return;
	}
	
	if (self.origin_z < self.owner.orig_origin_z)
		self.origin_z = self.owner.orig_origin_z;
	
	oself = self;
	self = self.owner;
	SHUB_CalcMove( oself.origin, mvspd, nihilanth_idle1 );
	self = oself;
	self.owner.building = world;
	dremove(self);
};

void () hurtball_touch =
{
	T_RadiusDamage (self, self.owner, 100, 270, world, MOD_HLIFE);
	WriteByte (4,23);
	WriteByte (4,3);
	WriteCoord (4,self.origin_x);
	WriteCoord (4,self.origin_y);
	WriteCoord (4,self.origin_z);
	multicast (self.origin,1);
	
	dremove(self);
};

void () voreball_touch =
{
	T_RadiusDamage (self, self.owner, 70, 100, world, MOD_HLIFE);
	WriteByte (4,23);
	WriteByte (4,3);
	WriteCoord (4,self.origin_x);
	WriteCoord (4,self.origin_y);
	WriteCoord (4,self.origin_z);
	multicast (self.origin,1);
	
	dremove(self);
};

void () voreball_home =
{
	local vector dir;
	local vector vtemp;

	vtemp = (self.enemy.origin + '0 0 10');
	if ((self.enemy.health <= 1) || self.enemy.classname != "player")
	{
		remove (self);
		return;
	}
	dir = normalize ((vtemp - self.origin));
	if ((skill == MOVETYPE_WALK))
	{
		self.velocity = (dir * self.has_tesla);
	}
	else
	{
		self.velocity = (dir * self.has_tesla);
	}
	self.nextthink = (time + 0.2);
	self.think = voreball_home;
};

void () teleball_touch =
{
	local entity tdest;
	local string tdstr;
	local float i, foundit;

	if (other.classname != "player" || other.health <= 0) {
		dremove(self);
		return;
	}
	
	i = 1;
	while (i < 10) {
		tdest = find( world, classname, "trigger_teleport" );
		while (tdest) {
			tdstr = strcat("n_teleport", ftos(i));
			tdstr = strzone(tdstr);
			if (tdest.targetname == tdstr) {
				foundit = 1;
				_bprint(tdest.targetname, " is tdest targ!\n");
				strunzone(tdstr);
				setorigin( other, (tdest.absmin+tdest.absmax)*.5 );
				other.velocity = '0 0 0';
				dremove(self);
				return;
			}
			strunzone(tdstr);
			tdest = find( tdest, classname, "trigger_teleport" );
		}
		i++;
	}
		
	
	dremove(self);
};

void (vector org, entity shooter) LaunchMortars = {

   local float xdir;
   local float ydir;
   local float zdir;

   xdir = ((150 * random ()) - 75);
   ydir = ((150 * random ()) - 75);
   zdir = (40 * random ());
   newmis = spawn ();
   newmis.owner = shooter;
   newmis.movetype = 10;
   newmis.solid = 2;
   newmis.classname = "grenade";
   newmis.weapon = 10;
   newmis.touch = voreball_touch;
   newmis.think = voreball_touch;
   newmis.nextthink = ((time + 2) + random ());
   newmis.velocity_x = (xdir * 2);
   newmis.velocity_y = (ydir * 2);
   newmis.velocity_z = (zdir * 15);
   newmis.avelocity = '250 300 400';
   setmodel (newmis,"progs/lavaball.mdl");
   setsize (newmis,'0 0 0','0 0 0');
   setorigin (newmis,org);

};

void () mortarball_touch =
{
	local float i;

   while (i < 6) 
   {
		LaunchMortars ((self.origin + '0 0 -1'),self.owner);
		i++;
   }
};

void() monster_wizard_spawn =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	self.velocity = '0 0 0';
	
	setmodel (self, "progs/wizard.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 80;

	self.th_stand = wiz_stand1;
	self.th_walk = wiz_walk1;
	self.th_run = wiz_run1;
	self.th_missile = wiz_fast1;
	self.th_pain = Wiz_Pain;
	self.th_die = wiz_die;
		
	self.classname = "monster_wizard";
	
	flymonster_start ();
};

void () desolidify =
{
	self.solid = SOLID_BBOX;
	if (self.think1) {
		self.think = self.think1;
		self.nextthink = time;
	}
};

void ( float fdelay, float fspeed, entity t_plyr ) teleball_throw =
{
	local entity teleball;
	
	teleball = spawn ();
	teleball.owner = self;
	teleball.movetype = MOVETYPE_FLY;
	setmodel (teleball, "progs/v_spike.mdl");
	setsize (teleball, VEC_ORIGIN, VEC_ORIGIN);
	teleball.origin = (self.origin + '0 0 10');
	teleball.velocity = ((t_plyr.origin - self.origin) * fspeed);
	teleball.avelocity = '300 300 300';
	teleball.nextthink = (time);
	teleball.think1 = voreball_home;
	teleball.enemy = t_plyr;
	teleball.touch = teleball_touch;
	teleball.takedamage = 1;
	teleball.th_die = teleball_touch;
	teleball.health = 25;
	
	teleball.has_tesla = fspeed;
	
	teleball.think = desolidify;
	teleball.nextthink = time + .3;
};

void ( float fdelay, float fspeed, entity t_plyr ) mortarball_throw =
{
	local entity mortarball;

	mortarball = spawn ();
	mortarball.owner = self;
	mortarball.movetype = MOVETYPE_FLY;
	setmodel (mortarball, "progs/lavaball.mdl");
	setsize (mortarball, VEC_ORIGIN, VEC_ORIGIN);
	mortarball.origin = (self.origin + '0 0 10');
	mortarball.velocity = ((t_plyr.origin - self.origin) * fspeed);
	mortarball.avelocity = '300 300 300';
	mortarball.nextthink = (time);
	mortarball.think1 = voreball_home;
	mortarball.enemy = t_plyr;
	mortarball.touch = mortarball_touch;
	mortarball.takedamage = 1;
	mortarball.th_die = mortarball_touch;
	mortarball.health = 25;
	
	mortarball.has_tesla = fspeed;
	
	mortarball.think = desolidify;
	mortarball.nextthink = time + .3;
}

void ( float fdelay, float fspeed, entity t_plyr ) voreball_throw =
{
	local entity voreball;

	voreball = spawn ();
	voreball.owner = self;
	voreball.movetype = MOVETYPE_FLY;
	setmodel (voreball, "progs/v_spike.mdl");
	setsize (voreball, VEC_ORIGIN, VEC_ORIGIN);
	voreball.origin = (self.origin + '0 0 10');
	voreball.velocity = ((t_plyr.origin - self.origin) * fspeed);
	voreball.avelocity = '300 300 300';
	voreball.nextthink = (time);
	voreball.think1 = voreball_home;
	voreball.enemy = t_plyr;
	voreball.touch = voreball_touch;
	voreball.takedamage = 1;
	voreball.th_die = voreball_touch;
	voreball.health = 25;
	
	voreball.has_tesla = fspeed;
	
	voreball.think = desolidify;
	voreball.nextthink = time + .3;
}

void ( float fdelay, float fspeed, entity t_plyr ) spawnball_throw =
{
	local entity nmon;

	nmon = spawn ();
	nmon.origin = (self.origin + '0 0 244');
	nmon.velocity_z = 3000;
	nmon.velocity_x = (-100 + (random () * 2000));
	nmon.velocity_y = (-100 + (random () * 2000));
	nmon.flags = 256;
	nmon.solid = 1;
	nmon.movetype = MOVETYPE_FLY;
	setsize (nmon, '-16 -16 0', '16 16 56');
	setmodel(nmon, "");
	nmon.solid = SOLID_BBOX;
	nmon.think = monster_wizard_spawn;
	nmon.nextthink = time + 1.5;
};
	
void ( float fdelay, float fspeed, entity t_plyr ) hurtball_throw =
{
	local entity hurtball;

	hurtball = spawn();
	hurtball.owner = self;
	hurtball.touch = hurtball_touch;
	hurtball.movetype = MOVETYPE_FLY;
	setorigin(hurtball, self.origin);
	setmodel(hurtball, "progs/lavaball.mdl");
	hurtball.effects = EF_BRIGHTLIGHT;
	hurtball.velocity = (t_plyr.origin - self.origin) * fspeed;
	hurtball.think = desolidify;
	hurtball.nextthink = time + .3;
};

void () shubmover_think =
{
	// shub has 4 phases of attack which overlap
	local entity t_plyr, oself;
	local float rnd;
	
	if (self.owner.health <= 0) {
		remove(self);
		return;
	}
	
	oself = self;
	self = self.owner;
	
	if (self.health > 3000) {								// PHASE 1
		t_plyr = find( world, classname, "player" );
		while (t_plyr) {
			if (visible(t_plyr))
			{
				if (random() < .7) {
					hurtball_throw( 0, 350, t_plyr );
				}
				else {
					voreball_throw( 0, 400, t_plyr );
				}
			
			}
			t_plyr = find( t_plyr, classname, "player" );
		}
	}
	else if (self.health > 2000) {							// PHASE 2
		t_plyr = find( world, classname, "player" );
		while (t_plyr) {
			if (visible(t_plyr))
			{
				rnd = random();
				if (rnd > .7) {
					voreball_throw( 0, 400, t_plyr );
				}
				else if (rnd > .3) {
					teleball_throw( 0, 400, t_plyr );
				}
				else {
					hurtball_throw( 0, 500, t_plyr );
				}
			
			}
			t_plyr = find( t_plyr, classname, "player" );
		}
	}
	else if (self.health > 1000) {							// PHASE 3
		t_plyr = find( world, classname, "player" );
		while (t_plyr) {
			if (visible(t_plyr))
			{
				rnd = random();
				if (rnd > .7) {
					voreball_throw( 0, 400, t_plyr );
				}
				else if (rnd > .3) {
					mortarball_throw( 0, 600, t_plyr );
				}
				else {
					teleball_throw( 0, 400, t_plyr );
				}
			
			}
			t_plyr = find( t_plyr, classname, "player" );
		}
	}
	else if (self.health > 0) {								// PHASE 4
		t_plyr = find( world, classname, "player" );
		while (t_plyr) {
			if (visible(t_plyr))
			{
				rnd = random();
				if (rnd > .6) {
					mortarball_throw( 0, 700, t_plyr );
				}
				else if (rnd > .2) {
					voreball_throw( 0, 550, t_plyr );
				}
				else {
					spawnball_throw( 0, 1000, t_plyr );
				}
			
			}
			t_plyr = find( t_plyr, classname, "player" );
		}
	}
	
	self = oself;
	
	self.think = shubmover_think;
	self.nextthink = time + random()*5;
};

void () nihilanth_pain =
{
	//_bprint(ftos(self.health), " is health\n");
};

void () nihilanth_explode =
{
	// throw tons of meat chunks	
	local	vector	oldo;
	local	float	x, y, z;
	local	float	r;

	sound (self, CHAN_VOICE, "boss2/pop2.wav", 1, ATTN_NORM);
	
	oldo = self.origin;

	z = 16;
	while (z <= 144)
	{
		x = -64;
		while (x <= 64)
		{
			y = -64;
			while (y <= 64)
			{
				self.origin_x = oldo_x + x;
				self.origin_y = oldo_y + y;
				self.origin_z = oldo_z + z;

				r = random();
				if (r < 0.3)				
					ThrowGib ("progs/gib1.mdl", -999);
				else if (r < 0.6)
					ThrowGib ("progs/gib2.mdl", -999);
				else
					ThrowGib ("progs/gib3.mdl", -999);
				y = y + 32;
			}
			x = x + 32;
		}
		z = z + 96;
	}
	self.effects = 128;
};

void () nihilanth_end_touch =
{
	local entity tend, tend2;
	
	if (other.classname != "player" || other.health <= 0)
		return;

	tend = find( world, targetname, "n_ending");
	if (tend) {
		tend2 = find( world, targetname, tend.target);
		if (tend2 != world)
			other.origin = tend2.origin;
		else
			other.origin = tend.origin;
		return;
	}
	bprint(2,"monster_nihilanth: no n_ending teleporter!\n");
	dremove(self);
};

void () nihilanth_finale =
{
	self.target = "n_dead";
	SUB_UseTargets();
	self.takedamage = 0;
	self.think = SUB_Null;
	self.velocity_z = -300;
	self.touch = nihilanth_end_touch;
	
	nihilanth_explode();
};

void () monster_nihilanth =
{
	local entity shubmover;

	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model2 ("progs/oldone.mdl");
	precache_model ("progs/lavaball.mdl");
	precache_model ("progs/v_spike.mdl");

	precache_sound2 ("boss2/death.wav");
	precache_sound2 ("boss2/idle.wav");
	precache_sound2 ("boss2/sight.wav");
	precache_sound2 ("boss2/pop2.wav");

	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;
	
	setmodel (self, "progs/oldone.mdl");
	setsize (self, '-160 -128 -24', '160 128 256');

	//self.use = nihilanth_use;
	
	self.health = 4000;	
	self.max_health = self.health;
	self.think = nihilanth_idle1;
	self.nextthink = time + 0.1;	
	self.takedamage = DAMAGE_YES;
	self.th_pain = nihilanth_pain;
	self.th_die = nihilanth_finale;
	shub = self;
	self.effects = EF_BRIGHTLIGHT;
	self.orig_origin = self.origin;
	
	
	shubmover = spawn();
	shubmover.owner = self;
	shubmover.origin = self.origin;
	shubmover.orig_origin = self.origin;
	shubmover.think = shubmover_think;
	shubmover.nextthink = time;
	
	total_monsters = total_monsters + 1;
	
	//Nihilanth_Throwspawns();
}


