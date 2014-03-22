// Half-life trigger and global variable ents

// hackish way of setting globals
void () env_global_use =
{
	localcmd("set ");
	localcmd(self.globalstate);
	localcmd(" 1\n");		//1 for ON
	
	bprint(2, "Global state set: ");
	bprint(2, self.globalstate);
	bprint(2, "\n");
};

// sets globals
void () env_global =
{
	self.use = env_global_use;

	if (self.initialstate == 1)
	{
		self.use();
		return;
	}
};

void () trigger_auto_go =
{
	local entity timer;

	if (self.delay) {
	  timer = spawn ();
	  timer.classname = "DelayedTimer";
	  timer.target = self.target;
	  timer.target = strzone(timer.target);
	  timer.nextthink = (time + self.delay);
	  timer.think = Delayed_Use;
	  dremove(self);
	  return;
	}
	else {
		SUB_UseTargets();
		dremove(self);
	}
};

#ifdef SVEN_COOP
void () trigger_auto_think =
{
	if (!self.globalstate || cvar(self.globalstate) == 1) {
		trigger_auto_go();
		if (self.spawnflags & 1)
			dremove(self);
	}
};

void () trigger_auto =
{
	self.think = trigger_auto_think;
	self.nextthink = time + 1;
};
#else
void () trigger_auto_think =
{
/*	if (num_players < 1) {
		self.nextthink = time + 3;
		return;
	}
*/
	if (!self.globalstate) {
		trigger_auto_go();
		return;
	}

	if (cvar(self.globalstate) == 1) {
	 hldprint(2,"WHEE AUTO ACTIVATED!\n");
		trigger_auto_go();
	}
	else {
		self.nextthink = time + 1;		// FIXME: this is improper usage of this entity. It needs to reactivate when a level is re-entered.
										// sven coop method works well, but is not meant for singleplayer consistency.
	}
};

void () trigger_auto =
{
	self.think = trigger_auto_think;
	self.nextthink = time + 5;
};
#endif
