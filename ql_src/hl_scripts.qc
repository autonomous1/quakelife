// Scripts handler (unfinished.. read note 1)
// Note 1: This is not meant to mimic half-life's scripted sequences system,
// as scientists and barneys are monsters in Quake-Life. scripted sequences 
// are only added here so players can make progress through maps.
// Note 2: scripted_sentence arein hl_sound.qc

void () script_path_remove =
{
	if (other != self.enemy)
		return;
		
	if (other.enemy == self)
		other.enemy = world;
	dremove(self);
};

void () move_actor =
{
	local entity oself;
	//local vector look_to;
	oself = self;
	//droptofloor();
	
	if (!self.enemy) {
		dremove(self);
		return;
	}
	if (!self.enemy.th_run) {
		// probably chthon or something
		dremove(self);
		return;
	}
	
	self.health = 20;
	self = self.enemy;
	self.enemy = oself;
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	self.nextthink = time + 0.1;
	self = oself;
	
	self.think = SUB_Remove;
	self.nextthink = time + 20;
	//SUB_CalcMoveEnt ( self.enemy, self.origin, 50, self.enemy.th_stand );
};

void () scripted_sequence_use =
{
//_bprint(ftos(self.spawnflags), " is me spawnflags and ", self.targetname, " is me targetname and ", self.target, " is me target\n");
	local entity targ, newmt;
	targ = find(world, targetname, self.m_iszEntity);
	
	if (targ != world) {
		if (self.m_fMoveTo > 2 || targ.health <= 0) {
			setorigin(targ, self.origin + '0 0 20');
			targ.npc_originalloc = self.origin + '0 0 30';
			targ.#npc_originalloc = self.origin + '0 0 30';
		}
		else {
			// walk or run to the destination. 
			hldprint(2,"walk or run here\n");
			newmt = spawn();
			newmt.origin = self.origin + '0 0 30';
			newmt.classname = "script_corner";
			newmt.netname = "script_path";
			newmt.solid = SOLID_TRIGGER;
			//setmodel(newmt, "progs/player.mdl");
			setsize (newmt, VEC_HULL_MIN, VEC_HULL_MAX );//'-8 -8 -8', '8 8 8');
			newmt.enemy = targ;
			newmt.touch = script_path_remove;
			newmt.think = move_actor;
			newmt.nextthink = time;
			//targ.movetarget = self;
			//targ.target = newmt.netname;
		}
	}
	self.use = SUB_Null;
	SUB_UseTargets();
	dremove(self);
};

void () scripted_sequence_touch =
{
	local entity te;
	te = nextent(world);
	while (te != world)
	{
		if ( te.classname == self.m_iszEntity )
			if ( te.health > 0 )
				return;
		te = nextent(te); 
	}
	
	scripted_sequence_use();
};

void () scripted_sequence_findtrigger =
{
	local entity head;
	head = findradius(self.origin, 100);
	while(head)
	{
		if (head.classname == "player") {
			other = head;
			scripted_sequence_touch();
		}
		head = head.chain;
	}
	self.nextthink = time + .5;
};

void () scripted_sequence_fix =
{
	hldprint(2,"scripted_sequence_fix: nothing triggers me\n");
	self.touch = scripted_sequence_touch;
	self.think = scripted_sequence_findtrigger;
	self.nextthink = time + 1;
};

void () FindMyTrigger_think =
{
	local entity te, oself;
	local float foundit, i;
	oself=self;
	
	if (!self.owner) {
		dremove(self);
		return;
	}
	
	self = self.owner;
	
	foundit = 0;
	te = nextent(world);
	while (te != world)
	{
		if ( te.target == self.targetname ) {
			foundit = 1;
			break;
		}
		if ( te.classname == "multi_manager" ) {		// fixme: saner method to look through these :\
			tokenize(te.netname);
			while (argv(i) != string_null && argv(i) != "}") {
				if (argv(i) == self.targetname)
				{
					// OK, we found  a multi_manager that trigers us. No need to run automatically then..
					foundit=1;
					break;
				}
				i++;
			}
			i=0;
		}
		te = nextent(te); 
	}
	
	if (!foundit)
		oself.think1();
	else
		oself.th_die();
	
	self = oself;
	dremove(self);
};

void ( entity for_ent, float wait_time, void() found, void() notfound ) FindMyTrigger =
{
	local entity finder;
	
	finder = spawn();
	finder.owner = for_ent;
	finder.think = FindMyTrigger_think;
	finder.think1 = found;
	finder.th_die = notfound;
	finder.nextthink = time + wait_time;
};

void () scripted_sequence =
{
	if (self.m_iszEntity) {
		self.use = scripted_sequence_use;
		if (!self.targetname || self.spawnflags & 16) {		// if we're not targeted, that generally means we gotta look for something
			self.touch = scripted_sequence_touch;
			self.think = scripted_sequence_findtrigger;
			self.nextthink = time + 1;
		}
		else {
			FindMyTrigger(self, 3, scripted_sequence_fix, SUB_Null);
		}
	}
	else
		trigger_once();
};

// parse centerprint text from titles.txt
void () env_message_use =
{
	local float file, i;
	local string msgstr, a;
	local entity targ;
	
	file = fopen ("titles.txt", 0);
	
	while ( i < 1100 ) {
		a = fgets (file);
		//a = strzone(a);
		
		if (self.has_tesla == 1)
		{
			if (a == "}")
				break;
			if (a != "{") {
				msgstr = strcat(msgstr, a);
				msgstr = strcat(msgstr, "\n");
			}
		}
		
		if (a == self.message) {
			self.has_tesla = 1;
		}
		
		//strunzone(a);
		i++;
	}
	msgstr = strzone(msgstr);
	
	fclose( file );

	targ = find(world, classname, "player");
	while (targ)
	{
		centerprint(targ, msgstr);
		targ = find(targ, classname, "player");
	}
	bprint(2,msgstr);
	
	strunzone(msgstr);
};

void () env_message =
{
	self.use = env_message_use;
};