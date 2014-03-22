// Half-Life 1 multisource

//multisource: maybe complete
void () multisource_use =
{
	local entity te;
	local float i, args;
	
	
	te = find(world, target, self.targetname);
	while (te)
	{
		if (te.activated != #TRUE) {
			return;
		}
		te = find(te, monster_string, "on");
	}
	
	// look for multi_manager entities which may target this one
	te = find(world, classname, "multi_manager");
	while (te)
	{
		if (te.activated != #TRUE) {
			args = tokenize(te.netname);
			i = 1;
			while (argv(i) != string_null) {
				if (argv(i) == self.targetname && argv(i-1) != "targetname") {
					//_bprint(self.targetname, " is triggered by a  trigger_multiple\n");
					return;
				}
				i++;
			}

		}
		te = find(te, classname, "multi_manager");
	}
	
	
	if (self.globalstate) {
		if (cvar(self.globalstate) < 1) {
			bprint(2,"global state not set\n");
			return;
		}
	}
		
	hldprint(2,"I AM ACTIVATED TYPE 2\n");
	hldprint(2,self.targetname);
	hldprint(2," 222\n");
	self.activated = 1;
	SUB_UseTargets();
	dremove(self);	// look in subs.qc for why i do this
};

void () multisource =
{
	self.use = multisource_use;
	if (mapname == "c1a2")
		if (self.targetname == "button_lock")
			dremove(self);
};

// checks to see if the entity has a "master" (IE multisource)
float ( entity t_ent ) has_master =
{
	local entity t;
	
	if (!t_ent.master)
		return 0;
	
	t = find(world, targetname, t_ent.master);
	if (!t || t == world || t.activated == 1)
	{
		hldprint(2,"NO MASTER\n");
		return 0;
	}
	if (t.classname == "multisource") {
		if (t.globalstate)
			if (cvar(t.globalstate) > 0) {
				dremove(t);
				hldprint(2,"DE GLOBALIZED!\n");
				return 0;
			}
		return 1;
	}
	
	return 0;
};

// activate master (used on teleporters)
float ( entity t_ent ) activate_master =
{
	local entity t, oself;
	oself = self;
	
	if (!t_ent.master)
		return 0;
	
	t = find(world, targetname, t_ent.master);
	if (!t || t == world || t.activated == 1)
	{
		return 0;
	}
	if (t.classname == "multisource") {
		if (t.use) {
			self = t;
			self.use();
			self = oself;
			return 1;
		}
	}
	
	return 0;
};