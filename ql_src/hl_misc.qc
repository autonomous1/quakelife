// misc and/or un-finished ents

// health and armor (HEV suit) chargers
void () func_chargerunit_use =
{
	if (self.has_tesla == 0) {
		if (activator.health == activator.max_health)
			return;
		activator.health = activator.health + 5;
		if (activator.health > activator.max_health)
			activator.health = activator.max_health;
			
		self.max_health -= 5;
		
		if (self.max_health <= 0) {
			self.hl_use = SUB_Null;
			self.frame = 1;
		}
	}
	else if (self.has_tesla == 1) {
		if (activator.armorvalue == 200)
			return;
		activator.armorvalue = activator.armorvalue + 5;
		if (activator.armorvalue > 200)
			activator.armorvalue = 200;
			
		self.armorvalue -= 5;
		
		if (self.armorvalue <= 0) {
			self.hl_use = SUB_Null;
			self.frame = 1;
		}
	}
};

void () func_chargerunit =
{
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	self.hl_use = func_chargerunit_use;
};

void () func_healthcharger =
{
	self.has_tesla = 0;	// health unit
	self.max_health = 75;
	func_chargerunit();
};

void () func_recharge =
{
	self.has_tesla = 1;	// armor unit
	self.armorvalue = 75;
	func_chargerunit();
};

// generally used in the training levels..
void () func_guntarget_die =
{
	self.velocity = '0 0 0';
	self.think = SUB_Null;
	self.takedamage = 0;
	self.target = self.message;
	SUB_UseTargets();
};
void () func_guntarget =
{
	func_train();
	self.takedamage = 1;
	self.th_die = func_guntarget_die;
};

//trigger_gravity: changes gravity of the palyer that touches it. Not exactly rocket science.
void () trigger_gravity_touch =
{
	if (other.classname != "player")
		return;
		
	if (#HL_MAP)
		other.gravity = self.gravity * .65;	// adjust it slightly, since half-life players can jump farther generally
	else
		other.gravity = self.gravity;
		
	other.oldgravity = other.gravity;
};

void () trigger_gravity =
{
	InitTrigger();
	self.touch = trigger_gravity_touch;
};

// Items that trigger things (like the HEV suit)
void () world_items_touch =
{
	if (other.classname != "player")
		return;

	SUB_UseTargets();
	dremove(self);
};

void () world_items =
{
//	self.origin_z += 30;

	if (self.type == 42)		// health
	{
		item_health();
	}
	else if (self.type == 43)	// security?
	{
		item_armor1();
	}
	else if (self.type == 44)	// Battery?
	{
		item_armor2();
	}
	else if (self.type == 45)	// HEV
	{
		setmodel(self,"progs/player.mdl");
		self.solid = SOLID_TRIGGER;
		self.touch = world_items_touch;
	}
	else
	{
		setmodel(self,"progs/player.mdl");
		dprint("world_items: no .type\n");
		self.solid = SOLID_TRIGGER;
		//self.nextthink = time + 5;
		//self.think = world_items_touch;
		self.touch = world_items_touch;
	}
	
};

void () env_bubbles =
{
	air_bubbles();
};

// UNFINISHED/UNSTARTED ENTITIES:
//(and I'm sure there's more than that, I just haven't gotten around to em yet)

// env_sprite: Half-life sprites do not load properly or at all on most quake engines.
void () env_sprite_use =
{
	if (self.has_tesla == 0) {
		setmodel( self, self.model );
		self.has_tesla = 1;
	}
	else {
		setmodel( self, string_null );
		self.has_tesla = 0;
	}
};

void () env_sprite =
{
#ifdef ALLOW_HL_SPRITES
	precache_model( self.model );
	self.use = env_sprite_use;
	
	self.effects = self.effects & EF_ADDITIVE;		// so transparency works (val=32)
	
	if (self.spawnflags & 1 || self.spawnflags & 2) {
		setmodel( self, self.model );
		self.has_tesla = 1;
	}
	else
		setmodel( self, string_null );
		
	HalfLife_DoRender();
#endif
};

// env_render: change the rendering properties of target based on own properties.
// I hope I got this right.
void () env_render_use =
{
	local entity targ, oself;
	oself = self;
	
	targ = find( world, targetname, self.target );
	while (targ)
	{
		//_bprint( "Running render effects on ", targ.classname, " with targetname ", targ.targetname, "\n" );
		targ.rendermode = self.rendermode;
		targ.renderamt = self.renderamt;
		targ.rendercolor = self.rendercolor;
		self = targ;
		HalfLife_DoRender();
		self = oself;
		targ = find( targ, targetname, self.target );
	}
};

void () env_render =
{
	self.use = env_render_use;
};

// func_friction: changes player friction when touched
// Note: .friction value does nothing yet
void () func_friction_touch =
{
	if (other.classname != "player")
		return;
		
	other.friction_time = time + .1;
	other.friction_new = self.modifier*.01;	// .modifier value is between 0 and 100
	
	//_bprint("New friction: ", ftos(other.friction_new), "\n");
};

void () func_friction =
{
	self.solid = SOLID_TRIGGER;
	setmodel( self, self.model );
	self.movetype = MOVETYPE_NONE;
	self.touch = func_friction_touch;
	
	HalfLife_DoRender();
};

void () monster_scientist_dead =
{
	dremove(self);
}

void () monster_barney_dead =
{
	dremove(self);
}

void () info_node =
{
	self.solid = SOLID_TRIGGER;
	setsize (self, '-32 -32 -4', '32 32 4');
	//self.targetname = vtos (self.origin);
};



void () trigger_autosave =
{
	dremove(self);
};

void () light_spot =
{
	light ();
};

void () gibshooter =
{
	dremove(self);
};

// env_sound is a sound-shaper (IE adjusts sounds for hallways and such)
void () env_sound =
{
	dremove(self);
};

// EXTRAS_R4 STUFF:
//============================================================================
float VIEWONLY = 1;

void() shake_think =
{
	if (self.attack_finished < time) {// Done
		
		self.nextthink = -1;
		
		if (self.noise1)
			sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		
		return;
	}
	
	local	entity plyr;
	
	// Shake all players in the effect radius...
	
	plyr = findradius(self.origin, self.count);
	
	while(plyr)
	{
		if (plyr.classname == "player") {
			
			local float	d;
			
			// Scale effect by distance
			d = vlen(self.origin - plyr.origin);
			d = (self.count - d)/self.count;
			
			if (d > 0) {

				// shake up the view
				plyr.punchangle_x = -1 * (random() + (0.025*self.dmg*d));
				
				// push the player around
				if (plyr.flags & FL_ONGROUND && !self.spawnflags & VIEWONLY) {
					d = self.dmg*d;
					plyr.velocity_x = plyr.velocity_x + (random()*d*2 - d);
					plyr.velocity_y = plyr.velocity_y + (random()*d*2 - d);
					plyr.velocity_z = plyr.velocity_z + (random()*d);// always push up
				}	
			}
		}
		
		plyr = plyr.chain;
	}
	
	// keep going
	self.nextthink = time + 0.1;
};

void() shake_use =
{
	if (self.attack_finished > time) return;// already active

	// Start...
	
	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	
	self.attack_finished = time + self.wait;
	self.nextthink = time + 0.01;
};

/*QUAKED trigger_shake (.5 .5 .5) ? VIEWONLY
Earthquake trigger - shakes players in it's radius when active.
Strength of tremor is greatest at the centre.

"dmg"			Strength at center (default is 120)
"wait"			Duration of shake (default is 1)
"count"			Affect radius (defalt is 200)
"noise"			Noise to play when starting to shake
"noise1"		Noise to play when stopping
"targetname"	Must be triggered

Spawnflags:
"VIEWONLY"		Shakes the view, but player movement is not affected

*/
void() trigger_shake =
{	
	if (!self.targetname) objerror("trigger_shake without name");

	if (self.noise) precache_sound (self.noise);
	if (self.noise1) precache_sound (self.noise1);
	
	if (!self.dmg) self.dmg = 120;
	if (self.count <= 0) self.count = 200;
	if (self.wait <= 0) self.wait = 1.0;
	
	setorigin(self, self.origin);
	
	self.nextthink = -1;
	self.think = shake_think;
	self.use = shake_use;
};

void () env_shake =
{
	trigger_shake();
};

//============================================================================
float be_null;
string (string matname) hl_material_convert =
{
	local string st2;
	local float stlen;

	if (matname == "TOOLS/TOOLSSKYBOX")
		return "SKY";
	else if (matname == "TOOLS/TOOLSCLIP")
		return "AAATRIGGER";//"clip";		// hmm needs fixing because this may change per map
	else if (matname == "TOOLS/TOOLSNODRAW")
		return "sky";	// also hackish
	else if (matname == "TOOLS/TOOLSTRIGGER")
		return "AAATRIGGER";
	else if (matname == "TOOLS/GENERIC011")
		return "AAATRIGGER";
//	else if (matname == "TOOLS/GENERIC011")
//		return "GENERIC011";
	else if (matname == "TOOLS/TOOLSORIGIN")
		return "origin";
	else {
		stlen = strlen (matname);
		st2 = substr(matname , 0, 8);
		if (st2 == "HALFLIFE/" || st2 == "HALFLIFE") {
			return substr(matname , 9, stlen);
		}
		
		st2 = substr(matname , 0, 8);
		if (st2 == "LIQUIDS/") {
			return substr(matname , 8, stlen);
		}
		
		st2 = substr(matname , 0, 7);
		if (st2 == "decals/") {
			return substr(matname , 7, stlen);
		}
		
		st2 = substr(matname , 0, 5);
		if (st2 == "XENO/") {
			return substr(matname , 5, stlen);
		}
		
		return matname;
	}
	return matname;
};

string (string ms_size) ms_cme =
{
	local float ms_flsize;
	
	if (ms_size == ")")
		return ")";
	else if (ms_size == "(")
		return "(";
		
	ms_flsize = stof(ms_size);
	/*
	if (ms_flsize > 4090) {
		be_null = #TRUE;
		ms_flsize = 4090;
	}
	if (ms_flsize < -4090) {
		be_null = #TRUE;
		ms_flsize = -4090;
	}
		*/
	return ftos(ms_flsize);
}

// convert VMT maps to Hl1 maps (this is the biggest hackitude I've done yet)
void (float do_mats, string vmf_file, string end_file) parse_hl_map =
{
	local float file, file2, file3, file4, i, i3, args, keepwrite, notfilestart, vv2, vv3, firstclass, brackets, brnum;
	local float ent_num, last_ent_brush, total_brush_ents;
	local float cname_multi, multi_num, i_p_s;
	local float targeted;
	local string targeted_string;
	local string a,b,c,d;

	file = fopen (strcat("conv/",vmf_file,".vmf"), 0);
	file2 = fopen (strcat("conv/",end_file,".map"), 2);
	file3 = fopen (strcat("conv/",end_file,"_brushes.txt"), 2);
	file4 = fopen (strcat("conv/junk.txt"), 2);
	_bprint("Converting VMF to MAP\n");
	
	while ( i < 160000 ) {
		a = fgets (file);
		a = strzone(a);
		args = tokenize(a);	
		
		if (argv(0) == "editor"/* || argv(0) == "solid" */) {
			if (brackets > 0) {
				fputs (file2, "}");
				fputs (file2, "\n");
				brackets -= 1;
			}
			keepwrite = #FALSE;
			firstclass = #FALSE;
		}
		else if (argv(0) == "side") {

			keepwrite = #FALSE;
		}
		else if (argv(0) == "connections") {
			keepwrite = #FALSE;
			fgets (file);		// skip the opening bracket
			i3 = 0;
			c = "null";
			c = strzone(c);
			while (i3 < 30) {
				b = fgets (file);
				b = strzone(b);
				args = tokenize(b);	
				if (argv(0) == "}") {
					break;
				}
				
				args = tokenize(argv(1));
				
				if (!cname_multi) {
					if (targeted) {
						if (targeted == 1) {
							fputs (file4, "{ //TGE\n");
							fputs (file4, "\"classname\" \"multi_manager\"\n");
							fputs (file4, "\"targetname\" \"");
							fputs (file4, targeted_string);
							fputs (file4, "\"\n");
						}
						fputs (file4, "\"");
						fputs (file4, argv(0));
						fputs (file4, "\" ");
						fputs (file4, "\"");
						fputs (file4, argv(5));
						fputs (file4, "\"\n");
						targeted++;
					}
					else {
						fputs (file2, "\"target\" \"");
						fputs (file2, argv(0));
						fputs (file2, "\"\n");
						targeted = 1;
						targeted_string = argv(0);
						targeted_string = strzone(targeted_string);
					}
				}
				else {							// is a multi_manager... :(
					if (c != "null")
						if (c == argv(0))
							multi_num++;
						else
							multi_num = 0;
					c = argv(0);
					c = strzone(c);
					fputs (file2, "\"");
					fputs (file2, argv(0));
					if (multi_num > 0) {
						fputs (file2, "#");
						fputs (file2, ftos(multi_num));
					}	
					fputs (file2, "\" ");
					fputs (file2, "\"");
					fputs (file2, argv(5));
					fputs (file2, "\"\n");
				}
				strunzone(b);
				i3++;
			}
			if (targeted > 1) {
				fputs (file4, "}\n");
				targeted=0;
				strunzone(targeted_string);
			}
			strunzone(c);
		}
		else if (argv(0) == "solid") {
			fputs (file2, "{ // Brush ");
			fputs (file2, ftos(brnum));
			fputs (file2, "\n");
			brackets++;
			brnum++;
			keepwrite = #FALSE;
		}
		else if (argv(0) == "classname") {
			if (firstclass)
				if (brackets > 0) {
					fputs (file2, "}");
					fputs (file2, "\n");
					brackets -= 1;
				}
			else
				firstclass = #TRUE;
				
			fputs (file2, "{");
			if (ent_num > 0) {
				fputs (file2, " // Entity ");
				fputs (file2, ftos(ent_num));
				fputs (file2, "\n");
			}
			else
				fputs (file2, "\n");
			ent_num++;
			
			if (argv(1) == "worldspawn") {
				fputs (file2, "\"mapversion\" \"220\"\n");
				fputs (file2, "\"wad\" \"\\temp\\halflife1\\valve\\halflife.wad\"\n");
			}
			fputs (file2, "\"classname\" ");
			fputs (file2, "\"");
			fputs (file2, argv(1));
			fputs (file2, "\"\n");
			
			if (argv(1) == "multi_manager")
				cname_multi = #TRUE;			// special target parsing for this entity.
			else
				cname_multi = #FALSE;
			
			if (argv(1) == "info_player_start")
				i_p_s = #TRUE;
			else
				i_p_s = #FALSE;
				
			brackets++;
			if (targeted) {
				strunzone(targeted_string);
				targeted = 0;
			}
			keepwrite = #TRUE;
			
		}
		else if (argv(0) == "plane") {
			if (ent_num > 1 && last_ent_brush != ent_num) {
				fputs (file3, ftos(ent_num - 1));
				fputs (file3, "\n");
				last_ent_brush = ent_num;
				total_brush_ents++;
			}
			args = tokenize(argv(1));
			fputs (file2, "( ");
			fputs (file2, ms_cme(argv(1)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(2)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(3)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(4)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(5)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(6)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(7)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(8)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(9)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(10)));
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(11)));		//
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(12)));			//
			fputs (file2, " ");
			fputs (file2, ms_cme(argv(13)));			//
			fputs (file2, " ) ");
			args = tokenize(a);	
		}
		else if (argv(0) == "material") {
			if (brackets == 1) {
				fputs (file2, "\"");
				fputs (file2, argv(0));
				fputs (file2, "\" \"");
				fputs (file2, argv(1));
				fputs (file2, "\"\n");
			}
			else {
				if (!do_mats) {			// Don't write materials.. instead, make every texture "NULL"
					fputs (file2, "null ");
				}
				else {
					if (be_null == #TRUE) {
						fputs (file2, "NULL ");
						be_null = #FALSE;
					}
					else {
						fputs (file2, hl_material_convert(argv(1)));
						fputs (file2, " ");
					}
				}
			}
		}
		else if (argv(0) == "uaxis") {
			args = tokenize(argv(1));
			fputs (file2, "[ ");
			fputs (file2, argv(1));
			fputs (file2, " ");
			fputs (file2, argv(2));
			fputs (file2, " ");
			fputs (file2, argv(3));
			fputs (file2, " ");
			fputs (file2, argv(4));
			fputs (file2, " ] ");
			vv2 = stof(argv(6));
			args = tokenize(a);	
		}
		else if (argv(0) == "vaxis") {
			args = tokenize(argv(1));
			fputs (file2, "[ ");
			fputs (file2, argv(1));
			fputs (file2, " ");
			fputs (file2, argv(2));
			fputs (file2, " ");
			fputs (file2, argv(3));
			fputs (file2, " ");
			fputs (file2, argv(4));
			fputs (file2, " ] ");
			vv3 = stof(argv(6));
			args = tokenize(a);	
		}
		else if (argv(0) == "rotation") {
			fputs (file2, "0 ");
			fputs (file2, ftos(vv2));
			fputs (file2, " ");
			fputs (file2, ftos(vv3));
			fputs (file2, "\n");
		}
		else {
			if (keepwrite) {
				if (argv(0) == "target") {
					targeted_string = argv(1);
					targeted_string = strzone(targeted_string);
					targeted = 1;
				}
				fputs (file2, "\"");
				fputs (file2, argv(0));
				fputs (file2, "\" \"");
				if (i_p_s && argv(0) == "origin") {
					args = tokenize(argv(1));	
					fputs (file2, argv(0));
					fputs (file2, " ");
					fputs (file2, argv(1));
					fputs (file2, " ");
					fputs (file2, ftos(stof(argv(2))+36));
				}
				else if ( argv(0) == "texture" ) {
					fputs (file2, hl_material_convert(argv(1)));
				}
				else
					fputs (file2, argv(1));
				fputs (file2, "\"\n");
			}
		}
		strunzone(a);
		i++;
	}

	fclose( file );
	
	fputs( file4, "//end\n" );
	fclose( file4 );
	file4 = fopen ("data/conv/junk.txt", 0);
	i=0;
	while (i < 300) {
		d = fgets(file4);
		d = strzone(d);
		if (d == "//end") {
			strunzone(d);
			break;
		}
		fputs (file2, d);
		fputs (file2, "\n");
		strunzone(d);
		i++;
	}

	fclose( file4 );
	fputs (file2, "//end\n");
	fclose( file2 );
	
	fputs (file3, "Total brush entities excluding world: ");
	fputs (file3, ftos(total_brush_ents));
	fputs (file3, "\n");

	fclose( file3 );
	
	fclose( file4 );
	bprint(2,"LET THE PARSING END2!\n");
};

// hl_swap_ents: Takes the brush ents from a .map file and the non-brush ents from an .ent file
// and creates a new .ent file with a hybrid of both (used for porting the sven coop map ents)
void ( string map_file, string ent_file, string end_ent_file ) hl_swap_ents =
{
	local float file, file2, file3, file4, args;
	local float i, i2, i3, spawnorg;
	local float brush_ent, brush_num, nowrite;
	local string ff, ff2, ff3, ff4;

	file = fopen (strcat("data/conv/",map_file,".map"), 0);
	file2 = fopen (strcat("conv/",ent_file,".ent"), 0);
	file3 = fopen (strcat("conv/",map_file,"_brushes.txt"), 0);
	
	if (file == -1) {
		_bprint("file not found\n");
		return;
	}
	if (file2 == -1) {
		_bprint("file2 not found\n");
		return;
	}
	if (file3 == -1) {
		_bprint("file3 not found\n");
		return;
	}
	
	if (!end_ent_file)
		end_ent_file = strcat(ent_file,"_hyb");
	
	file4 = fopen (strcat("conv/",end_ent_file,".ent"), 2);
	i=0;
	i2=0;
	
	ff3 = fgets (file3);
	ff3 = strzone(ff3);
	brush_ent = stof(ff3);
	strunzone(ff3);
	
	fputs( file4, ff2 );
	fputs( file4, "// Converted using XavioR's Quake-Life Map Tools\n" );
	
	while (i2 < 100) {
		ff2 = fgets (file2);
		ff2 = strzone(ff2);
		args = tokenize(ff2);
		if (argv(0) == "}" ) {
			strunzone(ff2);
			break;
		}
		
		fputs( file4, ff2 );
		fputs( file4, "\n" );
		strunzone(ff2);
		i2++;
	}
	fputs( file4, "}\n" );
	
	i2=0;
	i=0;
	while ( i < 50000 ) {
		ff = fgets (file);
		ff = strzone(ff);
		args = tokenize(ff);
		//
		if (ff == strcat("{ // Entity ", ftos(brush_ent)) || ff == "{ //TGE" ) {
			strunzone(ff);
			fputs (file4, "{\n");
			
			if (ff != "{ //TGE") {
				brush_num++;
				fputs( file4, "\"model\" \"*" );
				fputs( file4, ftos(brush_num) );
				fputs( file4, "\"\n" );
			}
			while (i2 < 25) {
				ff = fgets (file);
				ff = strzone(ff);
				args = tokenize(ff);

				if (argv(0) == "}" || argv(0) == "{") {
					strunzone(ff);
					break;
				}
				
				if (argv(0) == "spawnorigin")
					spawnorg = 1;
				
				if (argv(0) == "origin" && !spawnorg) {}
				else {
					fputs( file4, "\"" );
					fputs (file4, argv(0));
					fputs( file4, "\" \"" );
					fputs (file4, argv(1));
					fputs (file4, "\"\n");
				}
				strunzone(ff);
				i2++;
			}
			spawnorg = 0;
			fputs (file4, "}\n");
			i2 = 0;
			// setup next brush ent
			ff3 = fgets (file3);
			ff3 = strzone(ff3);
			brush_ent = stof(ff3);
			strunzone(ff3);
			// k, done with that, now lets parse this!
		}
		else {
			strunzone(ff);
		}
		i++;
	}
	
	i2 = 0;
	i = 0;
	while (i2 < 10000) {
		ff2 = fgets (file2);
		ff2 = strzone(ff2);
		args = tokenize(ff2);
		if (argv(0) == "" ) {
			strunzone(ff2);
			break;
		}
		if (argv(0) == "{" ) {
			strunzone(ff2);
			ff2 = fgets (file2);
			ff2 = strzone(ff2);
			args = tokenize(ff2);
			//_bprint(substr(ff2, 9, 1),"\n");
			if (substr(ff2, 9, 1) == "*") {
				nowrite = #TRUE;
			}
			else {
				nowrite = #FALSE;
				fputs( file4, "{\n" );
				fputs( file4, "\"" );
				fputs (file4, argv(0));
				fputs( file4, "\" \"" );
				fputs (file4, argv(1));
				fputs (file4, "\"\n");
			}

			while (i < 25) {
				ff2 = fgets (file2);
				ff2 = strzone(ff2);
				args = tokenize(ff2);

				if (argv(0) == "}" || argv(0) == "{") {
					strunzone(ff2);
					break;
				}
				if (nowrite == #FALSE) {
					fputs( file4, "\"" );
					fputs (file4, argv(0));
					fputs( file4, "\" \"" );
					fputs (file4, argv(1));
					fputs (file4, "\"\n");
				}
				strunzone(ff2);
				i++;
			}
			if (nowrite == #FALSE)
				fputs( file4, "}\n" );
			i=0;
		}
		else
			strunzone(ff2);
		i2++;
	}
	
	fputs (file4, "//end\n");
	fclose( file );
	fclose( file2 );
	fclose( file3 );
	fclose( file4 );
	
};

void () hl_batch_convert =
{
	local float file, i, args;
	local string ff2;

	file = fopen (strcat("conv/batch_convert.txt"), 0);
	
	if (file == -1) {
		_bprint("hl_batch_convert: conv/batch_convert.txt not found\n");
		return;
	}

	while (i < 200) {
		ff2 = fgets (file);
		ff2 = strzone(ff2);
		args = tokenize(ff2);
		if (!argv(0)) {
			break;
		}
		parse_hl_map( #TRUE, argv(0), argv(0) );
		i++;
	}
	_bprint("Conversions complete.\n");
};

/*
	local float file, file2, file3, file4, args;
	local float i, i2, i3;
	local float brush_ent;
	local string ff, ff2, ff3, ff4;

	local string cname, gname, tname, targname, oname;

	
	file = fopen (strcat("data/conv/",map_file,".txt"), 0);
	file2 = fopen (strcat("conv/",ent_file,".ent"), 0);
	file3 = fopen (strcat("conv/",map_file,"_brushes.txt"), 0);
	
	if (file == -1) {
		_bprint("file not found\n");
		return;
	}
	if (file2 == -1) {
		_bprint("file2 not found\n");
		return;
	}
	if (file3 == -1) {
		_bprint("file3 not found\n");
		return;
	}
	
	// First thing we want to do is grab the .map file to be, and grab info about the individual brush ents
	file4 = fopen (strcat("conv/",map_file,"_brushes_detailed.txt"), 2);
	i=0;
	i2=0;
	
	ff3 = fgets (file3);
	ff3 = strzone(ff3);
	brush_ent = stof(ff3);
	strunzone(ff3);
	
	while ( i < 50000 ) {
		if (brush_ent == 0)
			break;
	
		ff = fgets (file);
		ff = strzone(ff);
		args = tokenize(ff);
		//
		if (ff == strcat("{ // Entity ", ftos(brush_ent)) ) {
			strunzone(ff);
			fputs (file4, ftos(brush_ent));
			fputs (file4, "\n");
			fputs (file4, "{\n");
			while (i2 < 25) {
				ff = fgets (file);
				ff = strzone(ff);
				args = tokenize(ff);

				if (ff == "}") {
					strunzone(ff);
					break;
				}
				
				if (argv(0) == "classname") {
					fputs (file4, "classname ");
					fputs (file4, argv(1));
					fputs (file4, "\n");
				}
				else if (argv(0) == "globalname") {
					fputs (file4, "globalname ");
					fputs (file4, argv(1));
					fputs (file4, "\n");
				}
				else if (argv(0) == "targetname") {
					fputs (file4, "targetname ");
					fputs (file4, argv(1));
					fputs (file4, "\n");
				}
				else if (argv(0) == "target") {
					fputs (file4, "target ");
					fputs (file4, argv(1));
					fputs (file4, "\n");
				}
				else if (argv(0) == "origin") {
					fputs (file4, "origin ");
					fputs (file4, "\"");
					fputs (file4, argv(1));
					fputs (file4, "\"\n");
				}
				strunzone(ff);
				i2++;
			}
			fputs (file4, "}\n");
			i2 = 0;
			// setup next brush ent
			ff3 = fgets (file3);
			ff3 = strzone(ff3);
			brush_ent = stof(ff3);
			strunzone(ff3);
			// k, done with that, now lets parse this!
		}
		else {
			strunzone(ff);
		}
		i++;
	}
	fputs (file4, "//end\n");
	fclose( file );
	fclose( file2 );
	fclose( file3 );
	fclose( file4 );
	
	_bprint( "Detailing the ents done, processing the .ent now\n" );
	
	file = fopen (strcat("data/conv/",map_file,"_detailed.txt"), 0);
	
	file4 = fopen (strcat("conv/",ent_file,"_mixdetail.txt"), 2);
	file2 = fopen (strcat("conv/",ent_file,".ent"), 0);
	
	i=0;
	while (i < 10000) {
		ff2 = fgets (file2);
		ff2 = strzone(ff2);
		if (ff2 == string_null)
			break;
		args = tokenize(ff2);
		if (argv(0) == "model" && substr(argv(1), 0, 1) == "*") {
			file3 = fopen (strcat("conv/junk/",ent_file,"_mixdetail.txt"), 2);
		}
		i++;
	}
/*
	i=0;
	i2=0;
	i3=0;
	while (i3 < 10000) {
		ff = fgets(file);
		ff = strzone(ff);
		if (ff == "//end") {
			break;
		}
		
		cname = "null";
		gname = "null";
		tname = "null";
		targname = "null";
		oname = "null";
		
		brush_ent = stof(ff);
		end_brush = 0;
		
		strunzone(ff);
		i=0;
		while (i<8) {
			ff = fgets (file);
			ff = strzone(ff);
			if (ff == "}") {
				strunzone(ff);
				break;
			}
			args = tokenize(ff);
			if (argv(0) == "classname") {
				cname = argv(1);
				cname = strzone(cname);
			}
			else if (argv(0) == "globalname") {
				gname = argv(1);
				gname = strzone(gname);
			}
			else if (argv(0) == "targetname") {
				tname = argv(1);
				tname = strzone(tname);
			}
			else if (argv(0) == "target") {
				targname = argv(1);
				targname = strzone(targname);
			}
			else if (argv(0) == "origin") {
				oname = argv(1);
				oname = strzone(oname);
			}
			strunzone(ff);
			i++;
		}
		
		i=0;
		file2 = fopen (strcat("conv/",ent_file,".ent"), 0);
		while ( i < 10000 ) {
			ff2 = fgets (file2);
			ff2 = strzone(ff2);
			if (ff2 == string_null)
				break;
			args = tokenize(ff2);
			if (argv(0) == "model" && substr(argv(1), 0, 1) == "*") {
				end_brush = stof(substr(argv(1), 1, 3));
				fputs (file4, "\n{\n");
				
				ent_match = 5;
				while (i2 < 25) {
					ff = fgets (file2);
					ff = strzone(ff);
					args = tokenize(ff);

					if (ff == "}") {
						strunzone(ff);
						break;
					}
					
					if (argv(0) == "classname") {
						if (cname == "null")
							ent_match -= 1;
						else if (argv(1) != cname)
							ent_match -= 1;
					}
					else if (argv(0) == "globalname") {
						if (gname == "null")
							ent_match -= 1;
						else if (argv(1) != gname)
							ent_match -= 1;
					}
					else if (argv(0) == "targetname") {
						if (tname == "null")
							ent_match -= 1;
						else if (argv(1) != tname)
							ent_match -= 1;
					}
					else if (argv(0) == "target") {
						if (targname == "null")
							ent_match -= 1;
						else if (argv(1) != targname)
							ent_match -= 1;
					}
					else if (argv(0) == "origin") {
						if (oname == "null")
							ent_match -= 1;
						else if (argv(1) != oname)
							ent_match -= 1;
					}
					strunzone(ff);
					i2++;
				}
				if (ent_match == 5)
			}
			strunzone (ff2);
			i++;
		}
		fclose(file2);
		
		strunzone(cname);
		strunzone(gname);
		strunzone(tname);
		strunzone(targname);
		strunzone(oname);
		
		i3++;
	}
	strunzone (ff2);
	fclose(file2);
	_bprint("detailing the ents done\n");
	

};
*/