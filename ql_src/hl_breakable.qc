// breakables sounds
#define matGlass		0
#define matWood			1
#define matMetal		2
#define matFlesh		3
#define matCinderBlock	4
#define matCeilingTile	5
#define matComputer		6
#define matUnbreakableGlass	7
#define matRocks		8
#define matNone			9
#define matLastMaterial	10

void () pSoundsWood  = 
{
	//precache_model ("progs/gibs/wood1.mdl");	// crashes clients
	precache_model ("progs/gibs/wood2.mdl");
	//precache_model ("progs/gibs/wood3.mdl");	// crashes clients
	precache_model ("progs/gibs/wood4.mdl");

	precache_sound( "debris/wood1.wav" );
	precache_sound( "debris/wood2.wav" );
	precache_sound( "debris/wood3.wav" );
};

void () pSoundsFlesh  = 
{
	precache_model ("progs/gibs/flesh1.mdl");
	precache_model ("progs/gibs/flesh2.mdl");
	//precache_model ("progs/gibs/flesh3.mdl");		// crashes clients
	precache_model ("progs/gibs/flesh4.mdl");

	precache_sound( "debris/flesh1.wav" );
	precache_sound( "debris/flesh2.wav" );
	precache_sound( "debris/flesh3.wav" );
	precache_sound( "debris/flesh5.wav" );
	precache_sound( "debris/flesh6.wav" );
	precache_sound( "debris/flesh7.wav" );
};

void () pSoundsMetal  = 
{
	precache_model ("progs/gibs/vent1.mdl");
	precache_model ("progs/gibs/vent2.mdl");
	precache_model ("progs/gibs/vent3.mdl");
	precache_model ("progs/gibs/vent4.mdl");
	precache_model ("progs/gibs/vent5.mdl");
	precache_model ("progs/gibs/vent6.mdl");
	precache_model ("progs/gibs/vent7.mdl");

	precache_sound( "debris/metal1.wav" );
	precache_sound( "debris/metal2.wav" );
	precache_sound( "debris/metal3.wav" );
};

void () pSoundsConcrete  = 
{
	precache_model ("progs/gibs/rockgib_big.mdl");
	precache_model ("progs/gibs/rockgib_med.mdl");
	precache_model ("progs/gibs/rockgib_small.mdl");

	precache_sound( "debris/concrete1.wav" );
	precache_sound( "debris/concrete2.wav" );
	precache_sound( "debris/concrete3.wav" );
};


void () pSoundsGlass  = 
{
	precache_model ("progs/gibs/glass1.mdl");
	precache_model ("progs/gibs/glass2.mdl");
	//precache_model ("progs/gibs/glass3.mdl");		// crashes clients
	precache_model ("progs/gibs/glass4.mdl");
	precache_model ("progs/gibs/glass5.mdl");
	precache_model ("progs/gibs/glass6.mdl");
	precache_model ("progs/gibs/glass7.mdl");
	
	precache_sound( "debris/glass1.wav" );
	precache_sound( "debris/glass2.wav" );
	precache_sound( "debris/glass3.wav" );
};	



void () vyrovnani =
{
	self.angles_x = 0;
	self.angles_y = 0;
	self.think = SUB_Remove;
	self.nextthink = ((time + TE_LAVASPLASH) + (random () * TE_LAVASPLASH));
};

void (string gibname, float dm) ThrowGlass =
{
	local entity glass;

	glass = spawn ();
	glass.alpha = self.alpha;
	self.dest = ((self.mins + self.maxs) * 0.5);
	glass.origin = ((self.dest + (random () * '0 50 50')) - (random () * '0 50 50'));
	setmodel (glass, gibname);
	setsize (glass, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (glass, ((self.dest + (random () * '0 50 50')) - (random () * '0 50 50')));
	glass.movetype = MOVETYPE_BOUNCE;
	glass.solid = SOLID_NOT;
	glass.velocity = VelocityForDamage (dm);
	glass.avelocity = VelocityForDamage (dm);
	glass.think = vyrovnani;
	glass.nextthink = (time + 1.5);
};

void ( string bksnd ) set_break_sound =
{
	precache_sound(bksnd);
	if (!self.noise1)
		self.noise1 = bksnd;
	else
		self.noise2 = bksnd;
	
};

void ( string psnd ) random_pain_sound =
{
	if (!self.noise3)
		self.noise3 = psnd;
	else if (random() < .3)
		self.noise3 = psnd;
};

void () nmsound =
{
	if (self.has_tesla == 1)
		sound (self, CHAN_VOICE, self.owner.noise1, 1, ATTN_NORM);
	else if (self.has_tesla == 2)
		sound (self, CHAN_VOICE, self.owner.noise2, 2, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, self.owner.noise3, 1, ATTN_NORM);

	dremove(self);
};

void () func_breakable_pain =
{
	local float i;
	local entity oself;
	oself=self;
	
	switch (self.material)
	{
		case matComputer:
			break;
		case matGlass:
		case matUnbreakableGlass:
			random_pain_sound/*0*/ ( "debris/glass1.wav" );
			random_pain_sound/*1*/ ( "debris/glass2.wav" );
			random_pain_sound/*2*/ ( "debris/glass3.wav" );
			i = 3;
			break;

		case matWood:
			random_pain_sound/*0*/ ( "debris/wood1.wav" );
			random_pain_sound/*1*/ ( "debris/wood2.wav" );
			random_pain_sound/*2*/ ( "debris/wood3.wav" );
			i = 3;
			break;

		case matMetal:
			random_pain_sound/*0*/ ( "debris/metal1.wav" );
			random_pain_sound/*1*/ ( "debris/metal3.wav" );
			random_pain_sound/*2*/ ( "debris/metal2.wav" );
			i = 2;
			break;

		case matFlesh:
			random_pain_sound/*0*/ ( "debris/flesh1.wav" );
			random_pain_sound/*1*/ ( "debris/flesh2.wav" );
			random_pain_sound/*2*/ ( "debris/flesh3.wav" );
			random_pain_sound/*3*/ ( "debris/flesh5.wav" );
			random_pain_sound/*4*/ ( "debris/flesh6.wav" );
			random_pain_sound/*5*/ ( "debris/flesh7.wav" );
			i = 6;
			break;

		case matRocks:
			break;
		case matCinderBlock:
			random_pain_sound/*0*/ ( "debris/concrete1.wav" );
			random_pain_sound/*1*/ ( "debris/concrete2.wav" );
			random_pain_sound/*2*/ ( "debris/concrete3.wav" );
			i = 3;
			break;

		case matCeilingTile:
			// UNDONE: no ceiling tile shard sound yet
			i = 0;
			break;
	}
	
	if (self.noise3) {
		newmis = spawn();
		newmis.owner = self;
		newmis.origin = ((self.absmax+self.absmin)*.5);
		self = newmis;
		nmsound();
		self = oself;
	}
};

void(string rubblename) hlThrowRubble =
{
	local	entity new;
	
	new = spawn();
	new.origin = ((self.absmax+self.absmin)*.5);//self.origin;
	new.alpha = self.alpha;
	setmodel (new, rubblename );
	setsize (new, '0 0 0', '0 0 0');
	new.velocity_x = 70 * crandom();
	new.velocity_y = 70 * crandom();
	new.velocity_z = 140 + 70 * random();
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_BBOX;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	//new.touch = hlRubbleTouch;
	new.ltime = time;
	new.nextthink = time + 7 + random()*10;
	self.pausetime = time;
	new.frame = 0;
	new.flags = 0;
};

void () Breakaway  = {
	local entity itsp, oself;
	local float usesnd;
	
	oself = self;
	if (self.spawnobject > 0) {		// spawn armor, health, or whatever this should give the player
		itsp = spawn();
		itsp.spawnobject = self.spawnobject;
		setorigin(itsp, ((self.absmin+self.absmax)*.5));
		self = itsp;
		SetSpawnObject();
		self = oself;
		self.building = itsp;
	}	
	 
	if (self.noise1 || self.noise2) {			// play death noise and create specified rubble
		if (self.noise2)
			if (random() < .51)
				usesnd = 2;
			else
				usesnd = 1;
		else
			usesnd = 1;
			
		newmis = spawn();
		newmis.owner = self;
		newmis.origin = ((self.absmax+self.absmin)*.5);
		newmis.has_tesla = usesnd;
		self = newmis;
		nmsound();
		self = oself;
	}
	 
	// throw rubble
	switch (self.material)
	{
		case matComputer:
		case matGlass:
			ThrowGlass ("progs/gibs/glass1.mdl", self.health);
			ThrowGlass ("progs/gibs/glass2.mdl", self.health);
			ThrowGlass ("progs/gibs/glass6.mdl", self.health);	// used to be glass3, but glass3 is teh CRASH
			ThrowGlass ("progs/gibs/glass4.mdl", self.health);
			ThrowGlass ("progs/gibs/glass5.mdl", self.health);
			ThrowGlass ("progs/gibs/glass6.mdl", self.health);
			ThrowGlass ("progs/gibs/glass7.mdl", self.health);
			break;
		case matUnbreakableGlass:
			ThrowGlass ("progs/gibs/glass1.mdl", self.health);
			ThrowGlass ("progs/gibs/glass2.mdl", self.health);
			ThrowGlass ("progs/gibs/glass6.mdl", self.health);	// used to be glass3, but glass3 is teh CRASH
			ThrowGlass ("progs/gibs/glass4.mdl", self.health);
			ThrowGlass ("progs/gibs/glass5.mdl", self.health);
			ThrowGlass ("progs/gibs/glass6.mdl", self.health);
			ThrowGlass ("progs/gibs/glass7.mdl", self.health);
			break;

		case matWood:
			ThrowGlass ("progs/gibs/wood2.mdl", self.health);
			ThrowGlass ("progs/gibs/wood2.mdl", self.health);
			ThrowGlass ("progs/gibs/wood4.mdl", self.health);
			ThrowGlass ("progs/gibs/wood4.mdl", self.health);
			break;

		case matMetal:
			ThrowGlass ("progs/gibs/vent1.mdl", self.health);
			ThrowGlass ("progs/gibs/vent2.mdl", self.health);
			ThrowGlass ("progs/gibs/vent3.mdl", self.health);
			ThrowGlass ("progs/gibs/vent4.mdl", self.health);
			ThrowGlass ("progs/gibs/vent5.mdl", self.health);
			ThrowGlass ("progs/gibs/vent6.mdl", self.health);
			ThrowGlass ("progs/gibs/vent7.mdl", self.health);
			break;

		case matFlesh:
			ThrowGlass ("progs/gibs/flesh1.mdl", self.health);
			ThrowGlass ("progs/gibs/flesh2.mdl", self.health);
			ThrowGlass ("progs/gibs/flesh1.mdl", self.health);		// flesh3 crashes
			ThrowGlass ("progs/gibs/flesh4.mdl", self.health);
			break;

		case matRocks:
			ThrowGlass ("progs/gibs/rockgib_big.mdl", self.health);
			ThrowGlass ("progs/gibs/rockgib_med.mdl", self.health);
			ThrowGlass ("progs/gibs/rockgib_small.mdl", self.health);
			break;
		case matCinderBlock:
			ThrowGlass ("progs/gibs/rockgib_big.mdl", self.health);
			ThrowGlass ("progs/gibs/rockgib_med.mdl", self.health);
			ThrowGlass ("progs/gibs/rockgib_small.mdl", self.health);
			break;

		case matCeilingTile:
			hlThrowRubble( "progs/frubble1.mdl" );
			hlThrowRubble( "progs/frubble2.mdl" );
			hlThrowRubble( "progs/frubble3.mdl" );
			break;
	}
	 /*
	  hlThrowRubble( "progs/frubble1.mdl" );
	  hlThrowRubble( "progs/frubble2.mdl" );
	  hlThrowRubble( "progs/frubble3.mdl" );
	  */
      self.solid = SOLID_NOT;
      setmodel (self,string_null);
	  SUB_UseTargets();
	  

	  
	  dremove(self);		// don't stick around, since we're not a multiplayer game
 };


void () Breakuse = {


//   if ( (self.spawnflags & 1.000 || !self.spawnflags) ) {
	self.use = SUB_Null;
      Breakaway();
      self.spawnflags = (self.spawnflags - 1.000);
/*
   } else {

      self.solid = 4.000;
      setmodel (self,self.mdl);
      self.spawnflags = (self.spawnflags + 1.000);
	  SUB_UseTargets();
   }
*/
};

void () Breaktouch = {

  if (other.classname != "player") return;

      Breakaway();

};
 

void () func_breakable = {
	local entity itsp, oself;
	
	oself = self;
	if (self.spawnobject > 0) {
		// mainly to precache the item.. don't worry about it yet.
		itsp = spawn();
		itsp.spawnobject = self.spawnobject;
		self = itsp;
		SetSpawnObject();
		self = oself;
		dremove(itsp);
	}
	
	self.solid = 4.000;
	self.movetype = 7.000;

	precache_model( "progs/frubble1.mdl" );
	precache_model( "progs/frubble2.mdl" );
	precache_model( "progs/frubble3.mdl" );
	
	if (#HL_MAP) {//self.globalname) {
		setorigin(self, (((self.absmax+self.absmin)*.5)));	
	}
	else
		setorigin (self, self.origin);
      self.mdl = self.model;
	setmodel (self, self.mdl);
	setsize (self, self.mins , self.maxs);
//	if (self.rendermode == 2)
//		self.model = "" );

    if (self.spawnflags & 1.000){ 

      if (self.targetname)

         self.use = Breakuse; 

     } else {

         if (self.health) {
            self.takedamage = 1.000;
            self.th_die = Breakaway;
         }
      }
      if (self.spawnflags & 2.000){ 

         self.touch = Breaktouch;
      }

	    if (self.targetname)
			self.use = Breakuse; 

	if (mapname == "c2a3e" && self.targetname == "intro_box")
	{
		self.target = strzone(self.target);
		self.nextthink = time + 2;
		self.think = Delayed_Use;
	}
	
	self.th_pain = func_breakable_pain;
	
	

	
	if (self.material == matWood)		// wood
		pSoundsWood();
	else if (self.material == matMetal)	// metal
		pSoundsMetal();
	else if (self.material == matFlesh)	// flesh
		pSoundsFlesh();
	else if (self.material == matCinderBlock)	// cinder blocks
		pSoundsConcrete();
	else if (self.material == matCeilingTile)	// ceiling tiles
		pSoundsConcrete();
	else if (self.material == matComputer)	// computer
		pSoundsConcrete();	
	else if (self.material == matRocks)	// computer
		pSoundsConcrete();	
	else 
		pSoundsGlass();
		
    switch (self.material) 
	{
		case matWood:
			set_break_sound("debris/bustcrate1.wav");
			set_break_sound("debris/bustcrate2.wav");
			break;
		case matFlesh:
			set_break_sound("debris/bustflesh1.wav");
			set_break_sound("debris/bustflesh2.wav");
			break;
		case matComputer:
			//set_break_sound("buttons/spark5.wav");
			//set_break_sound("buttons/spark6.wav");
			set_break_sound("debris/bustmetal1.wav");
			set_break_sound("debris/bustmetal2.wav");
			break;
		case matUnbreakableGlass:
			set_break_sound("debris/bustglass1.wav");
			set_break_sound("debris/bustglass2.wav");
			break;
		case matGlass:
			set_break_sound("debris/bustglass1.wav");
			set_break_sound("debris/bustglass2.wav");
			break;
		case matMetal:
			set_break_sound("debris/bustmetal1.wav");
			set_break_sound("debris/bustmetal2.wav");
			break;
		case matCinderBlock:
			set_break_sound("debris/bustconcrete1.wav");
			set_break_sound("debris/bustconcrete2.wav");
			break;
		case matRocks:
			set_break_sound("debris/bustconcrete1.wav");
			set_break_sound("debris/bustconcrete2.wav");
			break;
		case matCeilingTile:
			set_break_sound ("debris/bustceiling.wav");  
			break;
	}
	
	HalfLife_DoRender();
};