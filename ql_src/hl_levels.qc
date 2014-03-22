// handle the transition of levels and such
// and landmarks
void () trigger_transition_touch =
{
	local entity oself;
	if (self.activated < time)
		return;
	if (other.classname != "player")
		return;
	if (next_transition_use > time)
		return;
		
	if (self.enemy != world) {
		oself = self;
		self = self.enemy;
		changelevel_touch();
		self = oself;
		self.enemy = world;
		next_transition_use = time + 5;
	}
};

void () trigger_transition =
{
	InitTrigger();
	self.touch = trigger_transition_touch;
};

// are we transitioning from another level?
float () HalfLife_UseLandmark =
{
	local string lmstats;
	
	lmstats = infokey (world, "landmark");
	
	if (!lmstats || lmstats == string_null)
		return #FALSE;
	else
		return #TRUE;
};

// Transition_Use:
// when a level is changed, there's sometimes a door that's supposed to open that the previous level tells the new level
void () Transition_Use =
{
	local entity targ;
	targ = find(world, targetname, self.target);
	if (targ.classname == "door")
		if (targ.spawnflags & 1 || targ.state == STATE_TOP) {
			strunzone(self.target);
			dremove(self);
			return;
		}
	if (mapname == "c0a0c") {
		strunzone(self.target);
		dremove(self);
		return;
	}
	SUB_UseTargets();
	strunzone(self.target);
	dremove(self);
};

// Singleplayer transitions (hackish)
//(also handles doors and such with properties that carry over..)
void () info_landmark =
{
#ifdef SVEN_COOP
	// sven coop maps dont rely on landmarks to my knowledge. It's all executed in the mapname .cfg file.
	//ADDME: make sure there IS another map we can go to? (see changelevel func in client.qc)
#else
	local entity ips, nips;
	local string lmstats, lmcht;
	
	
	if (HalfLife_UseLandmark() == #FALSE) {
		//dremove(self);
		return;
	}
	
	// keep doors and such open through level transitions
	lmcht = infokey (world, "changetarget");
	if (lmcht && landmarked != #TRUE) {
		next_transition_use = time + 5;
		newmis = spawn();
		newmis.classname = "DelayedTimer";
		newmis.target = lmcht;
		newmis.target = strzone(newmis.target);
		newmis.nextthink = time + 1.5;
		newmis.think = Transition_Use;
		// don't remove the changetarget value, else the door won't stay open when you leave the next map!
	}
	
	lmstats = infokey (world, "landmark");
	if (lmstats != self.targetname) {
		//dremove(self);
		return;
	}
	
	ips = find(world, classname, "info_player_start");
	while (ips != world)
	{
		dremove(ips);
		ips = find(ips, classname, "info_player_start");
	}

	//localcmd("set landmark ");
	//localcmd("\"\"\n");
	
	nips = spawn();
	nips.origin_x = self.origin_x - cvar("landmark_x");
	nips.origin_y = self.origin_y - cvar("landmark_y");
	nips.origin_z = self.origin_z - cvar("landmark_z");
	nips.angles_x = cvar("landmark_ang_x");
	nips.angles_y = cvar("landmark_ang_y");
	nips.angles_z = cvar("landmark_ang_z");
	nips.classname = "info_player_start";

	// and now the map-specific hacks..
	//mainly these are for those maps where the player spawns on top of a moving platform
	if (lmstats == "lm_c1a3_da" && mapname == "c1a3a") {
		setorigin(nips, '831.4 -1050.8 -100.0');
		nips.angles = ' -1.6 -39.9 0.0';
	}
	else if (mapname == "c1a3b" && lmstats == "lm_c1a3_ab")
		setorigin(nips, '170.7 -888.9 680.2');
	else if (mapname == "c1a4b" && lmstats == "c1a4k_to_c1a4b")
		setorigin(nips, '-647.4 -3534.6 -960.4');
	else if (mapname == "c2a4e" && lmstats == "lm4")
		setorigin(nips, '-1485.6 2141.4 0.1');
	else if (mapname == "c3a2a" && lmstats == "c3a2f")
		setorigin(nips, '-1538.3 -368.5 38.1');		
	else if (mapname == "c1a0c" && lmstats == "c1a0etoc")		// this map actually needs an adjustment on the trigger_teleport destination
		setorigin(nips, '-2106 894 -1546');	
	else if (mapname == "c1a0a" && lmstats == "c1a0dtoa")
		setorigin(nips, '189 2109 753');	
		
	//dremove(self);
	//info_player_start ();
	

	
	
	landmarked = #TRUE;
	landmark_ent = self;
	bprint(2,"LANDMARK CREATED!\n");
#endif
};

void () HalfLife_SetupLandmark =
{
#ifdef SVEN_COOP
	// don't set up any landmark info on sven coop maps (not needed)
#else
	local entity tlandmark, ttrain;
	local vector ttorg;
	
	if (self.landmark) {
		localcmd("set landmark ");
		localcmd(self.landmark);
		localcmd("\n");
		//set xyz of player
		tlandmark = find(world, targetname, self.landmark);
		
		while (tlandmark)
		{
			if (tlandmark.classname == "info_landmark") {
				break;
			}
			tlandmark = find(tlandmark, targetname, self.landmark);
		}
		
		
		if (tlandmark.classname != "info_landmark") {
			bprint(2,"Warning: trigger_changelevel has a .landmark value but no landmark set\n");
			return;
		}
	
		localcmd("set landmark_x ");
		localcmd(ftos(tlandmark.origin_x - other.origin_x));
		localcmd("\n");
		localcmd("set landmark_y ");
		localcmd(ftos(tlandmark.origin_y - other.origin_y));
		localcmd("\n");
		localcmd("set landmark_z ");
		localcmd(ftos(tlandmark.origin_z - other.origin_z));
		localcmd("\n");
		//set angle of player
		localcmd("set landmark_ang_x ");
		localcmd(ftos(other.angles_x));
		localcmd("\n");
		localcmd("set landmark_ang_y ");
		localcmd(ftos(other.angles_y));
		localcmd("\n");
		localcmd("set landmark_ang_z ");
		localcmd(ftos(other.angles_z));
		localcmd("\n");
	}
	// setup a target for the next map
	if (self.changetarget) {
		localcmd("set changetarget ");
		localcmd(self.changetarget);
		localcmd("\n");
	}
	// setup train origin/continuation
	ttrain = find(world, classname, "tracktrain");
	while (ttrain) {
		if (ttrain.globalname != string_null) {
			//ttorg = ttrain.origin;
			ttorg = ttrain.origin;
			localcmd( "set " );
			localcmd( ttrain.globalname );
			localcmd( " \"" );
			localcmd( ftos(tlandmark.origin_x - ttorg_x) );
			localcmd( " " );
			localcmd( ftos(tlandmark.origin_y - ttorg_y) );
			localcmd( " " );
			localcmd( ftos(tlandmark.origin_z - ttorg_z) );
			localcmd( "\"\n" );
			
			localcmd( "set " );
			localcmd( ttrain.globalname );
			localcmd( "_ang \"" );
			localcmd( ftos(ttrain.angles_x) );
			localcmd( " " );
			localcmd( ftos(ttrain.angles_y) );
			localcmd( " " );
			localcmd( ftos(ttrain.angles_z) );
			localcmd( "\"\n" );
			
			if (!ttrain.reachtarget)
				localcmd( "set train_targ 0" );
			else {
				localcmd( "set train_targ " );
				localcmd( ttrain.reachtarget );
				localcmd( "\n" );
			}
		}
		ttrain = find(ttrain, classname, "tracktrain");
	}
#endif
}


