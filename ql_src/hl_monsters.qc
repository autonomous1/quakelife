// Convert Half-Life 1 monsters to quake 1
float chthon_spawned;		// only one monster_tentacle per map pls ;/

void () monster_human_grunt =
{
	self.origin_z += 30;
	monster_enforcer ();
	self.classname = "monster_enforcer";
};

void () monster_shocktrooper =
{
	monster_human_grunt();
};

void () monster_robogrunt =
{
	self.origin_z += 30;
	monster_demon1();
	self.classname = "monster_demon1";
};

void () monster_pitdrone =
{
	self.origin_z += 30;
	self.classname = "monster_hell_knight";
	monster_hell_knight();
};

void () monster_gonome =
{
	self.origin_z += 30;
	self.classname = "monster_ogre";
	monster_ogre();
};

void () monster_male_assassin =
{
	self.origin_z += 30;
	self.classname = "monster_tarbaby";
	monster_tarbaby();
};

void () monster_zombie_soldier =
{
	self.origin_z += 30;
	self.classname = "monster_shambler";
	monster_shambler();
};

void () monster_human_medic_ally =
{
	monster_human_grunt();
};

void () monster_human_grunt_ally =
{
	self.origin_z += 30;
	monster_army();
};

// yeah, evil scientists..
void () monster_scientist =
{
	self.origin_z += 30;
	monster_army();
};

void () monster_human_assassin =
{
	self.origin_z += 30;
	monster_tarbaby();
	self.classname = "monster_tarbaby";
};

// The flying guys that look like ripoffs from duke nukem
void () monster_alien_controller =
{
	self.origin_z += 30;
	monster_wizard();
	self.classname = "monster_wizard";
};

void () monster_bullchicken =
{
	self.origin_z += 30;
	monster_demon1();
	self.classname = "monster_demon1";
};

// the big-ass fish. Really need something better to replace this with :p
void () monster_ichthyosaur =
{
	self.origin_z += 30;
	monster_fish();		// this is going to look funny as hell in c2a3a by the bridge scene.. :)
	self.classname = "monster_fish";
};

// snarks: the small annoying little craps that you can collect and use as weapons
void () monster_snark =
{
	self.origin_z += 30;
	dremove(self); // eh, i got nothing?
};

//CHTHON!
void () monster_tentacle =
{
	//self.origin_z += 30;
	if (chthon_spawned != 1)
	{
		monster_killable_boss();
		boss_awake();
		self.health = 9999999999999999999999;	// i'm LAZY
		chthon_spawned = 1;
		return;
	}
	dremove(self);
};

void () monster_bigmomma =
{
	self.origin_z += 35;

	//if (self.netname)
	//	self.target = self.netname;
		
	// again with the really awkward monster replacement. Need something good 'ere!
	monster_shalrath();
	self.classname = "monster_shalrath";
};

// not implementing these, really
void () info_bigmomma_use =
{
	if (self.owner != world)
		if (self.owner.health > 0)
			return;
	SUB_UseTargets();
	if (self.reachtarget) {
		self.target = self.reachtarget;
		SUB_UseTargets();
	}
};

void () info_bigmomma =
{
	self.use = info_bigmomma_use;
	
	newmis = spawn();
	setorigin(newmis, self.origin);
	newmis.think = monster_bigmomma;
	newmis.nextthink = time;
	newmis.target = self.targetname;
	self.owner = newmis;
};

void () monster_cockroach =
{
	// ADDME
};

/*
// gold sent code from megatf coop (ignore)
void () sentryowner_think =
{
	if (!self.building) {
		dremove(self);
		return;
	}
	
	if (self.building.think != lvl3_sentry_stand) {
		self.building.weapon = 3;
		self.building.think = lvl3_sentry_stand;
		self.building.skin = 2.000000;
	}
	self.building.ammo_shells = 999;
	self.building.ammo_rockets = 999;
	self.nextthink = time + 1;
};

void () monster_sentry =
{
	// use sentrygun? WHY NOT! :p
	self.origin_z += 30;
	self.team_no = 2;
	self.netname = "monster team";
	TeamFortress_Build(2);
	
	self.think = sentryowner_think;
	self.nextthink = time + 10;
};
*/

void () monster_miniturret =
{
	self.team_no = 2;
	self.origin_z -= 30;
	monster_turret();
};

// no longer the peace maker.. now he's a man of ugliness and chainsaws!
void () monster_barney =
{
	self.origin_z += 30;
	monster_ogre();
};

void () monster_headcrab =
{
	self.origin_z += 30;
	monster_spider();
	self.classname = "monster_spider";		// ADDME: sight sound
};

// ADDME: honestly, quake doesnt have any ceiling-clinging monster I can think of :\
void () monster_barnacle =
{
	self.origin_z += 25;
	monster_dog();
	self.classname = "monster_dog";
};

void () monster_alien_grunt =
{
	self.origin_z += 30;
	monster_hell_knight();
	self.classname = "monster_hell_knight";
};

void () monster_leech =
{
	monster_fish();
	self.classname = "monster_fish";
};

void () monster_alien_slave =
{
	self.origin_z += 30;
	monster_knight();
	self.classname = "monster_knight";
};

void () monster_houndeye =
{
	self.origin_z += 30;
	monster_dog();
	self.classname = "monster_dog";
};

void () monster_gargantua =
{
	self.origin_z += 30;
	monster_shambler();
	self.classname = "monster_shambler";
};

// func_tank moved to hl_misc

// monster_tripmine: also the LTB as from catch22's mod BeyondTF 
void () LTB_Pain;
void () LTB_Explode;
void () LTB_Detonate;

void () LTB_Arm;
void () LTB_PreArm;


// lets make sure we can attack the LTB before we jump to any conclusions..
void () LTB_PreArm =
{
	local vector org;
	local vector targ;

	makevectors (self.angles);
	org = (self.origin + self.view_ofs);
//	targ = (org + (v_forward * 150));
	targ = (org + (v_forward * 187));	// extend max length
	traceline (org, targ, 0.000000, self);
	if ((trace_fraction == 1))
	{
		//sprint (self.real_owner, 2, "Walls must be closer together\n");
		//dremove(self);
		//return;
	}
	self.think = LTB_Arm;
	self.nextthink = time + .9;
};

// frames based on LTB beam size (these are here so I dont get confused >.<)
#define FRAME_25PERCENT		3
#define FRAME_50PERCENT		2
#define FRAME_75PERCENT		1
#define FRAME_100PERCENT	0
#define FRAME_125PERCENT	4

void () LTB_Arm =
{
	local vector org;
	local vector targ;
	local float dist;

	makevectors (self.angles);
	org = (self.origin + self.view_ofs);
	targ = (org + (v_forward * 187));
	traceline (org, targ, 0.000000, self);
	if ((trace_fraction == 1))
	{
		//sprint (self.real_owner, 2, "Walls must be closer together\n");
		//LTB_Explode ();
		//return;
	}
	if ((trace_ent.team_no == self.team_no))
	{
		self.nextthink = (time + 1);
		self.think = LTB_Arm;
		return;
	}
	if ((self.weapon == 0.000000))
	{
		self.weapon = 1;
	}
	if ((self.attack_finished < time))
	{
		self.movetype = 0.000000;
		self.solid = 2;
		self.takedamage = 1;
		// lets dynamize the beam size a bit..
		// First lets get a new model in with multiple lengths based on frames
//		setmodel (self, "progs/beamavi2.mdl");	// test mdl
		setmodel (self, "progs/tripbeam.mdl");
		// Now lets find a proper beam size..
		dist = vlen(org - trace_endpos);
		if (dist > 150)
			self.frame = #FRAME_125PERCENT;
		else if (dist > 112)
			self.frame = #FRAME_100PERCENT;
		else if (dist > 75)
			self.frame = #FRAME_75PERCENT;
		else if (dist > 37)
			self.frame = #FRAME_50PERCENT;
		else
			self.frame = #FRAME_25PERCENT;

		self.skin = (self.owner.team_no - 1);
		sound (self, 3, "weapons/tlaser.wav", 0.5, 1);
		self.attack_finished = (time + 0.02);
	}
	self.think = LTB_Arm;
	self.nextthink = (time + 0.07);
	if (other.team_no == self.team_no)
	{
		return;
	}
	if (((trace_ent.velocity != '0 0 0') || (trace_ent.flags & 32)))
	{
		LTB_Explode ();
		return;
	}
};

void () LTB_Detonate =
{
	self.th_pain = SUB_Null;
	self.th_die = SUB_Null;
	T_RadiusDamage (self, self.owner, 200, 200, world, MOD_HLIFE);
	WriteByte (0.000000, 23);
	WriteByte (0.000000, 3);
	WriteCoord (0.000000, self.origin_x);
	WriteCoord (0.000000, self.origin_y);
	WriteCoord (0.000000, self.origin_z);
	BecomeExplosion ();
};

void () LTB_Explode =
{
	sound (self, 3, "weapons/tarbeep.wav", 1, 1);
	self.nextthink = (time + 0.01);
	self.think = LTB_Detonate;
};

void () LTB_Pain =
{
	self.nextthink = (time + 0.02);
	self.think = LTB_Detonate;
	self.health = 10;
};

void () monster_tripmine =
{
	precache_model("progs/beam.mdl");		// LTB
	precache_model ("progs/tripbeam.mdl");		// New beam model
	precache_model ("progs/charge.mdl");
	precache_sound ("weapons/deploy.wav");
	precache_sound ("weapons/tlaser.wav");
	precache_sound ("weapons/tarbeep.wav");
	
	LTB_PreArm();
};

// monstermaker: INCOMPLETE (but works)
//(basically it teleports monsters to its' origin)
void () monstermaker_use =
{
	local entity te;
	local float foundit;

	te = nextent(world);
	while (te != world)
	{
		if ( te.owner == self ) {
			if ( te.health > 0 ) {
				foundit = #TRUE;
				break;
			}
		}
		te = nextent(te); 
	}

	if (te == world || !foundit) {
		dremove(self);
		return;
	}

	if (self.m_imaxlivechildren > 0) {	// incomplete!
		if ( self.owner != world )
			if ( self.owner.health > 0 ) {
				self.think = monstermaker_use;
				self.nextthink = time + self.delay;
				return;
			}
		self.owner = te;
	}
	te.angles = self.angles;
	setorigin(te, self.origin);
	te.target = self.target;
	te.owner = world;
	SUB_UseTargets();
	
	self.monstercount -= 1;
	if (self.monstercount <= 0)
		dremove(self);
	else {
		self.think = monstermaker_use;
		self.nextthink = time + self.delay;
	}
	
};

void () monstermaker =
{
	local entity newmon, oself;
	local float i;
	oself = self;
	
	if (!self.delay)
		self.delay = 2;
	
	self.origin_z += 25;	// account for the difference in hull sizes b/w half-life and quake monsters
	if (self.monstertype)
	{
		while (i < self.monstercount) {
			newmon = spawn();
			self = newmon;
			oself.monstertype();
			self = oself;
			newmon.owner = self;
			setorigin(newmon,'0 0 5000');	// i know, not really the most sane thing to do.. but then again when have i ever coded sanely? :p

			i++;
		}
		self.owner = world;//newmon;
		self.use = monstermaker_use;
	}
	else {
		bprint(2, "teleport_spawner: No monstertype specified.\n");
		dremove(self);
	}
	if (self.has_tesla) {
		self.think = monstermaker_use;
		self.nextthink = time + self.has_tesla;
	}
};

// final boss is in hl_nihilanth.qc
