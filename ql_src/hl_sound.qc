// Half-life sound (and scripted sentences)
string (string cstr) speaker_sound;
#define AMBIENT_SOUND_STATIC			0	// medium radius attenuation
#define AMBIENT_SOUND_EVERYWHERE		1
#define AMBIENT_SOUND_SMALLRADIUS		2
#define AMBIENT_SOUND_MEDIUMRADIUS		4
#define AMBIENT_SOUND_LARGERADIUS		8
#define AMBIENT_SOUND_START_SILENT		16
#define AMBIENT_SOUND_NOT_LOOPING		32
#define silent mtf_items
#define locked barrel
void ( string t_Target, float t_Time ) Delayed_Timer;
void () ambient_use;


void () speaker_unlock =
{
	self.owner.#locked = 0;
	dremove(self);
};

void () speaker_think =
{
	local float i;

	if (self.#locked != 1) {
		self.#locked = 1;
		tokenize(self.message);
		while (argv(i) != string_null) {
			newmis = spawn();
			newmis.#silent = #TRUE;
			newmis.origin = self.origin;
			newmis.targetname = strcat(argv(i), ftos(i));
			newmis.targetname = strzone(newmis.targetname);
			newmis.message = strcat("vox/", argv(i), ".wav");
			newmis.message = strzone(newmis.message);
			newmis.has_tesla = self.has_tesla;
			newmis.health = self.health;
			newmis.is_speaker = 2;
			newmis.use = ambient_use;
			Delayed_Timer( newmis.targetname, i);
			i++;
		}
		newmis = spawn();
		newmis.use = speaker_unlock;
		newmis.owner = self;
		newmis.targetname = strcat(argv(0), ftos(i));
		newmis.targetname = strzone(newmis.targetname);
		Delayed_Timer( newmis.targetname, i);
	}
};

void () ambient_use =
{

	if (self.is_speaker == 1) {
		speaker_think();
		return;
	}
	
	// volume can only be between 0 - 1 in quake (maybe FTE supports higher.. not sure)
	if (self.health > 1)
		self.health = 1;
	
	if (self.#silent == #TRUE) {
		if (self.spawnflags & AMBIENT_SOUND_NOT_LOOPING) {
			sound (self, CHAN_VOICE, self.message, self.health, self.has_tesla /*ATTN_NORM*/);
			
		}
		else {
			sound (self, CHAN_VOICE, self.message, self.health, self.has_tesla /*ATTN_NORM*/);
			ambientsound (self.origin, self.message, self.health, self.has_tesla /*ATTN_STATIC*/);
		}
		self.#silent = #FALSE;
	}
	else
	{
		if (self.spawnflags & AMBIENT_SOUND_NOT_LOOPING) {
			sound (self, CHAN_VOICE, self.message, 0, self.has_tesla /*ATTN_NORM*/);
		}
		else {
			sound (self, CHAN_VOICE, self.message, 0, self.has_tesla /*ATTN_NORM*/);
			ambientsound (self.origin, self.message, 0, self.has_tesla /*ATTN_STATIC*/);
		}
		self.#silent = #TRUE;
	}
	if (self.is_speaker == 2) {
		strunzone(self.targetname);
		strunzone(self.message);
		dremove(self);
		return;
	}
};

void () ambient_generic =
{
	local string link;
	local float i;

#ifdef DARKPLACES
	link = hl_script_str(strtoupper(self.message)/*self.message*/);
#else
	link = hl_script_str(strconv(2,0,0,self.message)/*self.message*/);
#endif
	
	if (link == "NOLINK") {
		if (substr(self.message , 0, 1) == "*")
			self.message = substr(self.message , 1, strlen(self.message));
	
	
		if (substr(self.message , 0, 1) == "!" || substr(self.message , 0, 1) == "*") {
			dremove(self);
			return;
		}
		else
			precache_sound(self.message);
	}
	else {
		if (self.is_speaker == #TRUE) {		// precache multiple sounds :\
			tokenize(link);
			while (argv(i) != string_null) {
				precache_sound(strcat("vox/", argv(i), ".wav"));
				i++;
			}
			self.message = link;
			self.message = strzone(self.message);
		}
		else {
			self.message = strcat(link, ".wav");
			self.message = strzone(self.message);
			precache_sound(self.message);
		}
	}
	
	if (self.spawnflags & AMBIENT_SOUND_SMALLRADIUS)
		self.has_tesla = ATTN_IDLE;
	else if (self.spawnflags & AMBIENT_SOUND_MEDIUMRADIUS)
		self.has_tesla = ATTN_STATIC;
	else if (self.spawnflags & AMBIENT_SOUND_LARGERADIUS)
		self.has_tesla = ATTN_NORM;
	else if (self.spawnflags & AMBIENT_SOUND_EVERYWHERE)
		self.has_tesla = ATTN_NONE;
	else
		self.has_tesla = ATTN_STATIC;

		
	if (self.health == 0)	// final vol
		self.health = 1;
		
	if (self.spawnflags & AMBIENT_SOUND_START_SILENT)
		self.#silent = 1;
	else
		ambientsound (self.origin, self.message, self.health, self.has_tesla /*ATTN_STATIC*/);
		
	self.use = ambient_use;
	//sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
	
	//dremove(self);
};

// scripted sentences - things that scientists trigger to give you dialogue and such
void () scripted_sentence_use =
{
	sound (self, CHAN_VOICE, self.sentence, 1, ATTN_NORM);
	self.use = SUB_Null;
	SUB_UseTargets();
	dremove(self);
};

void () scripted_sentence =
{
	local string link;
	
	if (checkextension("FTE_STRINGS"))
	{
		// same
	}
	
#ifdef DARKPLACES
	link = hl_script_str(strtoupper(self.sentence));
#else
	link = hl_script_str(strconv(2,0,0,self.sentence));
#endif
	link = strzone(link);
	
	if (link == "NOLINK")
	{
		if (substr(self.sentence , 0, 1) == "!") {
			dremove(self);
			return;
		}
		else
			precache_sound(self.sentence);
	}
	else {
		self.sentence = strcat(link, ".wav");
		self.sentence = strzone(self.sentence);
		precache_sound(self.sentence);
	}
	strunzone(link);
	
	self.use = scripted_sentence_use;
};

// EVIL HAX AWAIT:
//hl sentences.txt parser
void () parse_hl_crap =
{
	local float file, file2, i, i2, args;
	local string a;
	
	file = fopen ("sound/sentences.txt", 0);
	file2 = fopen ("sound/sentences_parsed.txt", 2);
	bprint(2,"LET THE PARSING BEGIN!\n");
	
	while ( i < 600 ) {
		a = fgets (file);
		a = strzone(a);
		if (a != "") {
			args = tokenize(a);
			if (argv(1) != "") {
				if (i == 0)
					fputs (file2, "if (cstr == \"" );
				else
					fputs (file2, "else if (cstr == \"!" );
				fputs (file2, argv(0));
				fputs (file2, "\") return \"" );
				i2 = 1;
				while (argv(i2) != string_null) {
					fputs (file2, argv(i2));
					if (argv(i2) != string_null)
						fputs (file2, " ");
					i2++;
				}
				fputs (file2, "\";\n");
			}
		}
		strunzone(a);
		i++;
	}
	fclose( file );
	fclose( file2 );
	bprint(2,"LET THE PARSING END!\n");
};

// hl_script_str: the HL text scripts, converted to if/else statements using parse_hl_crap.
string ( string cstr ) hl_script_str =
{
	if (cstr == "!BA_LATE") return "barney/c1a0_ba_late";
	else if (cstr == "!BA_HEADDOWN") return "barney/c1a0_ba_headdown";
	else if (cstr == "!BA_DESK") return "barney/c1a0_ba_desk";
	else if (cstr == "!BA_BUTTON") return "barney/c1a0_ba_button";
	else if (cstr == "!BA_HEVNO") return "barney/c1a0_ba_hevno";
	else if (cstr == "!BA_HEVYES") return "barney/c1a0_ba_hevyes";
	else if (cstr == "!BA_GLAD") return "barney/c1a1_ba_glad";
	else if (cstr == "!BA_BULLSQUID") return "barney/c1a2_ba_bullsquid";
	else if (cstr == "!BA_ZOMBIE2") return "barney/c1a2_ba_2zomb";
	else if (cstr == "!BA_ZOMBIE4") return "barney/c1a2_ba_4zomb";
	else if (cstr == "!BA_CLIMB") return "barney/c1a2_ba_climb";
	else if (cstr == "!BA_SLEW") return "barney/c1a2_ba_slew";
	else if (cstr == "!BA_SURFACE") return "barney/c1a2_ba_surface";
	else if (cstr == "!BA_TOPSIDE") return "barney/c1a2_ba_top";
	else if (cstr == "!BA_WHISPER") return "barney/c1a4_ba_wisp";
	else if (cstr == "!BA_TENTACLE") return "barney/c1a4_ba_octo1";
	else if (cstr == "!BA_HUB1A") return "barney/c2a1_ba_hub1a";
	else if (cstr == "!BA_HUB2A") return "barney/c2a1_ba_hub2a";
	else if (cstr == "!BA_AGAIN") return "barney/c2a1_ba_again";
	else if (cstr == "!BA_LAUNCH") return "barney/c2a2_ba_launch";
	else if (cstr == "!BA_ASSN") return "barney/c2a3_ba_assn";
	else if (cstr == "!BA_LONGNITE") return "barney/c2a4_ba_longnite";
	else if (cstr == "!BA_STERIL") return "barney/c2a4_ba_steril";
	else if (cstr == "!BA_TEACH") return "barney/c2a4_ba_teach";
	else if (cstr == "!BA_ARG1A") return "barney/c2a4_ba_arg1a";
	else if (cstr == "!BA_ARG2A") return "barney/c2a4_ba_arg3a";
	else if (cstr == "!BA_ARG3A") return "barney/c2a4_ba_arg5a";
	else if (cstr == "!BA_TAU1A") return "barney/c2a4_ba_1tau";
	else if (cstr == "!BA_TAU3A") return "barney/c2a4_ba_3tau";
	else if (cstr == "!BA_TAU5A") return "barney/c2a4_ba_5tau";
	else if (cstr == "!BA_ALIVE") return "barney/c2a4_ba_alive";
	else if (cstr == "!BA_LETMEOUT") return "barney/c2a5_ba_letout";
	else if (cstr == "!BA_RPG") return "barney/c2a5_ba_rpg";
	else if (cstr == "!BA_HELPME") return "barney/c2a5_ba_helpme";
	else if (cstr == "!BA_SNIPED") return "barney/c2a5_ba_sniped";
	else if (cstr == "!BA_SURVEY2A") return "barney/c3a2_ba_2surv";
	else if (cstr == "!BA_SURVEY4A") return "barney/c3a2_ba_4surv";
	else if (cstr == "!BA_SURVEY6A") return "barney/c3a2_ba_6surv";
	else if (cstr == "!BA_SURVEY8A") return "barney/c3a2_ba_8surv";
	else if (cstr == "!BA_PORTSTAY") return "barney/c3a2_ba_stay";
	else if (cstr == "!SC_OK0") return "scientist/excellentteam";
	else if (cstr == "!SC_OK1") return "scientist/fellowscientist";
	else if (cstr == "!SC_OK2") return "scientist/fine";
	else if (cstr == "!SC_OK3") return "scientist/hopeyouknow";
	else if (cstr == "!SC_OK4") return "scientist/leadtheway";
	else if (cstr == "!SC_OK5") return "scientist/letsgo";
	else if (cstr == "!SC_OK6") return "scientist/yesletsgo";
	else if (cstr == "!SC_OK7") return "scientist/yes3";
	else if (cstr == "!SC_OK8") return "scientist/alright";
	else if (cstr == "!SC_WAIT0") return "scientist/beenaburden";
	else if (cstr == "!SC_WAIT1") return "scientist/slowingyou";
	else if (cstr == "!SC_WAIT2") return "scientist/reconsider";
	else if (cstr == "!SC_WAIT3") return "scientist/whyleavehere";
	else if (cstr == "!SC_WAIT4") return "scientist/illwaithere";
	else if (cstr == "!SC_WAIT5") return "scientist/istay";
	else if (cstr == "!SC_WAIT6") return "scientist/illwait";
	else if (cstr == "!SC_STOP0") return "scientist/stop1";
	else if (cstr == "!SC_STOP1") return "scientist/stop2";
	else if (cstr == "!SC_STOP2") return "scientist/stop3";
	else if (cstr == "!SC_STOP3") return "scientist/stop4";
	else if (cstr == "!SC_STARE0") return "scientist/yees";
	else if (cstr == "!SC_STARE1") return "scientist/areyouthink";
	else if (cstr == "!SC_STARE2") return "scientist/noidea";
	else if (cstr == "!SC_HELLO0") return "scientist/hellothere";
	else if (cstr == "!SC_HELLO1") return "scientist/freemanalive";
	else if (cstr == "!SC_HELLO2") return "scientist/afellowsci";
	else if (cstr == "!SC_HELLO3") return "scientist/greetings2";
	else if (cstr == "!SC_HELLO4") return "scientist/hello";
	else if (cstr == "!SC_HELLO5") return "scientist/goodtoseeyou";
	else if (cstr == "!SC_HELLO6") return "scientist/newhevsuit";
	else if (cstr == "!SC_HELLO7") return "scientist/hellofromlab";
	else if (cstr == "!SC_HELLO8") return "scientist/inmesstoo";
	else if (cstr == "!SC_ANSWER0") return "scientist/notsure";
	else if (cstr == "!SC_ANSWER1") return "scientist/notcertain";
	else if (cstr == "!SC_ANSWER2") return "scientist/perhaps";
	else if (cstr == "!SC_ANSWER3") return "scientist/whocansay";
	else if (cstr == "!SC_ANSWER4") return "scientist/inconclusive";
	else if (cstr == "!SC_ANSWER5") return "scientist/theoretically";
	else if (cstr == "!SC_ANSWER6") return "scientist/whyaskme";
	else if (cstr == "!SC_ANSWER7") return "scientist/lowervoice";
	else if (cstr == "!SC_ANSWER8") return "scientist/ofcourse";
	else if (cstr == "!SC_ANSWER9") return "scientist/absolutely";
	else if (cstr == "!SC_ANSWER10") return "scientist/yes";
	else if (cstr == "!SC_ANSWER11") return "scientist/ibelieveso";
	else if (cstr == "!SC_ANSWER12") return "scientist/right";
	else if (cstr == "!SC_ANSWER13") return "scientist/imsure";
	else if (cstr == "!SC_ANSWER14") return "scientist/positively";
	else if (cstr == "!SC_ANSWER15") return "scientist/nodoubt";
	else if (cstr == "!SC_ANSWER16") return "scientist/yees";
	else if (cstr == "!SC_ANSWER17") return "scientist/ofcoursenot";
	else if (cstr == "!SC_ANSWER18") return "scientist/absolutelynot";
	else if (cstr == "!SC_ANSWER19") return "scientist/noo";
	else if (cstr == "!SC_ANSWER20") return "scientist/idontthinkso";
	else if (cstr == "!SC_ANSWER21") return "scientist/completelywrong";
	else if (cstr == "!SC_ANSWER22") return "scientist/cantbeserious";
	else if (cstr == "!SC_ANSWER23") return "scientist/dontknow";
	else if (cstr == "!SC_ANSWER24") return "scientist/ridiculous";
	else if (cstr == "!SC_ANSWER25") return "scientist/shutup";
	else if (cstr == "!SC_ANSWER26") return "scientist/noguess";
	else if (cstr == "!SC_ANSWER27") return "scientist/stopasking";
	else if (cstr == "!SC_ANSWER28") return "scientist/justasked";
	else if (cstr == "!SC_ANSWER29") return "scientist/repeat";
	else if (cstr == "!SC_QUESTION0") return "scientist/everseen";
	else if (cstr == "!SC_QUESTION1") return "scientist/needsleep";
	else if (cstr == "!SC_QUESTION2") return "scientist/areyouthink";
	else if (cstr == "!SC_QUESTION3") return "scientist/evergetout";
	else if (cstr == "!SC_QUESTION4") return "scientist/rightwayout";
	else if (cstr == "!SC_QUESTION5") return "scientist/cantbeworse";
	else if (cstr == "!SC_QUESTION6") return "scientist/rescueus";
	else if (cstr == "!SC_QUESTION7") return "scientist/fascinating";
	else if (cstr == "!SC_QUESTION8") return "scientist/stimulating";
	else if (cstr == "!SC_QUESTION9") return "scientist/luckwillchange";
	else if (cstr == "!SC_QUESTION10") return "scientist/hearsomething";
	else if (cstr == "!SC_QUESTION11") return "scientist/doyousmell";
	else if (cstr == "!SC_QUESTION12") return "scientist/uselessphd";
	else if (cstr == "!SC_QUESTION13") return "scientist/waithere";
	else if (cstr == "!SC_QUESTION14") return "scientist/survival";
	else if (cstr == "!SC_QUESTION15") return "scientist/headcrab";
	else if (cstr == "!SC_QUESTION16") return "scientist/goodpaper";
	else if (cstr == "!SC_QUESTION17") return "scientist/catchone";
	else if (cstr == "!SC_QUESTION18") return "scientist/dinner";
	else if (cstr == "!SC_QUESTION19") return "scientist/alientrick";
	else if (cstr == "!SC_QUESTION20") return "scientist/alienappeal";
	else if (cstr == "!SC_QUESTION21") return "scientist/rumorclean";
	else if (cstr == "!SC_QUESTION22") return "scientist/nothostile";
	else if (cstr == "!SC_QUESTION23") return "scientist/announcer";
	else if (cstr == "!SC_QUESTION24") return "scientist/smellburn";
	else if (cstr == "!SC_QUESTION25") return "scientist/noidea";
	else if (cstr == "!SC_QUESTION26") return "scientist/whatnext";
	else if (cstr == "!SC_IDLE0") return "scientist/ipredictedthis";
	else if (cstr == "!SC_IDLE1") return "scientist/containfail";
	else if (cstr == "!SC_IDLE2") return "scientist/chaostheory";
	else if (cstr == "!SC_IDLE3") return "scientist/howinteresting";
	else if (cstr == "!SC_IDLE4") return "scientist/neverseen";
	else if (cstr == "!SC_IDLE5") return "scientist/peculiarmarks";
	else if (cstr == "!SC_IDLE6") return "scientist/whoresponsible";
	else if (cstr == "!SC_IDLE7") return "scientist/nogrant";
	else if (cstr == "!SC_IDLE8") return "scientist/bloodsample";
	else if (cstr == "!SC_IDLE9") return "scientist/administrator";
	else if (cstr == "!SC_IDLE10") return "scientist/improbable";
	else if (cstr == "!SC_IDLE11") return "scientist/organicmatter";
	else if (cstr == "!SC_IDLE12") return "scientist/lambdalab";
	else if (cstr == "!SC_IDLE13") return "scientist/ihearsomething";
	else if (cstr == "!SC_NOGO") return "scientist/dontgothere";
	else if (cstr == "!SC_MONST0") return "scientist/seeheadcrab";
	else if (cstr == "!SC_MONST1") return "scientist/importantspecies";
	else if (cstr == "!SC_HEAR0") return "scientist/ihearsomething";
	else if (cstr == "!SC_HEAR1") return "scientist/didyouhear";
	else if (cstr == "!SC_HEAR2") return "scientist/whatissound";
	else if (cstr == "!SC_SMELL0") return "scientist/somethingfoul";
	else if (cstr == "!SC_SMELL1") return "scientist/odorfromyou";
	else if (cstr == "!SC_SMELL2") return "scientist/peculiarodor";
	else if (cstr == "!SC_SMELL3") return "scientist/stench";
	else if (cstr == "!SC_WOUND0") return "scientist/iwounded";
	else if (cstr == "!SC_WOUND1") return "scientist/iwounded2";
	else if (cstr == "!SC_MORTAL0") return "scientist/iwoundedbad";
	else if (cstr == "!SC_MORTAL1") return "scientist/iwounded2";
	else if (cstr == "!SC_CUREA") return "scientist/youlookbad";
	else if (cstr == "!SC_CUREB") return "scientist/youwounded";
	else if (cstr == "!SC_CUREC") return "scientist/youneedmedic";
	else if (cstr == "!SC_HEAL0") return "scientist/heal1";
	else if (cstr == "!SC_HEAL1") return "scientist/heal2";
	else if (cstr == "!SC_HEAL2") return "scientist/youneedmedic";
	else if (cstr == "!SC_HEAL3") return "scientist/youlookbad";
	else if (cstr == "!SC_HEAL4") return "scientist/youwounded";
	else if (cstr == "!SC_HEAL5") return "scientist/heal3";
	else if (cstr == "!SC_HEAL6") return "scientist/heal4";
	else if (cstr == "!SC_HEAL7") return "scientist/heal5";
	else if (cstr == "!SC_PLFEAR0") return "scientist/whatyoudoing";
	else if (cstr == "!SC_PLFEAR1") return "scientist/canttakemore";
	else if (cstr == "!SC_PLFEAR2") return "scientist/madness";
	else if (cstr == "!SC_PLFEAR3") return "scientist/noplease";
	else if (cstr == "!SC_PLFEAR4") return "scientist/getoutofhere";
	else if (cstr == "!SC_PLFEAR5") return "scientist/sorryimleaving";
	else if (cstr == "!SC_FEAR0") return "scientist/nooo";
	else if (cstr == "!SC_FEAR1") return "scientist/startle2";
	else if (cstr == "!SC_FEAR2") return "scientist/startle1";
	else if (cstr == "!SC_FEAR3") return "scientist/dontwantdie";
	else if (cstr == "!SC_FEAR4") return "scientist/getoutalive";
	else if (cstr == "!SC_FEAR5") return "scientist/startle3";
	else if (cstr == "!SC_FEAR6") return "scientist/startle4";
	else if (cstr == "!SC_FEAR7") return "scientist/startle5";
	else if (cstr == "!SC_FEAR8") return "scientist/startle6";
	else if (cstr == "!SC_FEAR9") return "scientist/startle7";
	else if (cstr == "!SC_FEAR10") return "scientist/startle8";
	else if (cstr == "!SC_FEAR11") return "scientist/startle9";
	else if (cstr == "!SC_FEAR12") return "scientist/startle1";
	else if (cstr == "!SC_SCREAM0") return "scientist/sci_fear1";
	else if (cstr == "!SC_SCREAM1") return "scientist/sci_fear2";
	else if (cstr == "!SC_SCREAM2") return "scientist/sci_fear3";
	else if (cstr == "!SC_SCREAM3") return "scientist/sci_fear4";
	else if (cstr == "!SC_SCREAM4") return "scientist/sci_fear5";
	else if (cstr == "!SC_SCREAM5") return "scientist/sci_fear6";
	else if (cstr == "!SC_SCREAM6") return "scientist/sci_fear7";
	else if (cstr == "!SC_SCREAM7") return "scientist/sci_fear8";
	else if (cstr == "!SC_SCREAM8") return "scientist/sci_fear9";
	else if (cstr == "!SC_SCREAM9") return "scientist/sci_fear10";
	else if (cstr == "!SC_SCREAM10") return "scientist/sci_fear11";
	else if (cstr == "!SC_SCREAM11") return "scientist/sci_fear12";
	else if (cstr == "!SC_SCREAM12") return "scientist/sci_fear13";
	else if (cstr == "!SC_SCREAM13") return "scientist/sci_fear14";
	else if (cstr == "!SC_SCREAM14") return "scientist/sci_fear15";
	else if (cstr == "!SC_SCARED0") return "scientist/whatyoudoing";
	else if (cstr == "!SC_SCARED1") return "scientist/stopattacking";
	else if (cstr == "!SC_SCARED2") return "scientist/youinsane";
	else if (cstr == "!SC_PHELLO0") return "scientist/hellofreeman";
	else if (cstr == "!SC_PHELLO1") return "scientist/greetings2";
	else if (cstr == "!SC_PHELLO2") return "scientist/goodtoseeyou";
	else if (cstr == "!SC_PHELLO3") return "scientist/greetings";
	else if (cstr == "!SC_PHELLO4") return "scientist/hello";
	else if (cstr == "!SC_PHELLO5") return "scientist/hellothere";
	else if (cstr == "!SC_PHELLO6") return "scientist/freeman";
	else if (cstr == "!SC_PQUEST0") return "scientist/beverage";
	else if (cstr == "!SC_PQUEST1") return "scientist/statusreport";
	else if (cstr == "!SC_PQUEST2") return "scientist/tunnelcalc";
	else if (cstr == "!SC_PQUEST3") return "scientist/shakeunification";
	else if (cstr == "!SC_PQUEST4") return "scientist/correcttheory";
	else if (cstr == "!SC_PQUEST5") return "scientist/analysis";
	else if (cstr == "!SC_PQUEST6") return "scientist/purereadings";
	else if (cstr == "!SC_PQUEST7") return "scientist/newsample";
	else if (cstr == "!SC_PQUEST8") return "scientist/perfectday";
	else if (cstr == "!SC_PQUEST9") return "scientist/cascade";
	else if (cstr == "!SC_PQUEST10") return "scientist/delayagain";
	else if (cstr == "!SC_PQUEST11") return "scientist/softethics";
	else if (cstr == "!SC_PQUEST12") return "scientist/tunedtoday";
	else if (cstr == "!SC_PQUEST13") return "scientist/donuteater";
	else if (cstr == "!SC_PQUEST14") return "scientist/seencup";
	else if (cstr == "!SC_PQUEST15") return "scientist/hungryyet";
	else if (cstr == "!SC_PQUEST16") return "scientist/recalculate";
	else if (cstr == "!SC_PQUEST17") return "scientist/checkatten";
	else if (cstr == "!SC_PIDLE0") return "scientist/hideglasses";
	else if (cstr == "!SC_PIDLE1") return "scientist/weartie";
	else if (cstr == "!SC_PIDLE2") return "scientist/runtest";
	else if (cstr == "!SC_PIDLE3") return "scientist/limitsok";
	else if (cstr == "!SC_PIDLE4") return "scientist/asexpected";
	else if (cstr == "!SC_PIDLE5") return "scientist/thatsodd";
	else if (cstr == "!SC_PIDLE6") return "scientist/allnominal";
	else if (cstr == "!SC_PIDLE7") return "scientist/shutdownchart";
	else if (cstr == "!SC_PIDLE8") return "scientist/reportflux";
	else if (cstr == "!SC_PIDLE9") return "scientist/simulation";
	else if (cstr == "!SC_PIDLE10") return "scientist/hopenominal";
	else if (cstr == "!SC_HAZ_OK0") return "holo/tr_sci_use";
	else if (cstr == "!SC_HAZ_WAIT0") return "holo/tr_sci_unuse";
	else if (cstr == "!SC_GOODWORK") return "holo/tr_sci_goodwork";
	else if (cstr == "!SC_HARDLYNOTICE") return "holo/tr_sci_hardlynoticed";
	else if (cstr == "!SC_NEXTSTATION") return "holo/tr_sci_nextstation";
	else if (cstr == "!SC_POK0") return "scientist/sci_alone";
	else if (cstr == "!SC_POK1") return "scientist/sci_bother";
	else if (cstr == "!SC_POK2") return "scientist/sci_busy";
	else if (cstr == "!SC_POK3") return "scientist/sci_aftertest";
	else if (cstr == "!SC_POK4") return "scientist/sci_somewhere";
	else if (cstr == "!SC_1MUMBLE") return "scientist/c1a0_sci_mumble";
	else if (cstr == "!SC_DISA") return "scientist/c1a0_sci_disa";
	else if (cstr == "!SC_DIS1A") return "scientist/c1a0_sci_dis1a";
	else if (cstr == "!SC_DIS1B") return "scientist/c1a0_sci_dis1b";
	else if (cstr == "!SC_DIS1C") return "scientist/c1a0_sci_dis1c";
	else if (cstr == "!SC_DIS1D") return "scientist/c1a0_sci_dis1d";
	else if (cstr == "!SC_DIS2A") return "scientist/c1a0_sci_dis2a";
	else if (cstr == "!SC_DIS3A") return "scientist/c1a0_sci_dis3a";
	else if (cstr == "!SC_DIS4A") return "scientist/c1a0_sci_dis4a";
	else if (cstr == "!SC_DIS5A") return "scientist/c1a0_sci_dis5a";
	else if (cstr == "!SC_DIS6A") return "scientist/c1a0_sci_dis6a";
	else if (cstr == "!SC_DIS7A") return "scientist/c1a0_sci_dis7a";
	else if (cstr == "!SC_DIS8A") return "scientist/c1a0_sci_dis8a";
	else if (cstr == "!SC_DIS9A") return "scientist/c1a0_sci_dis9a";
	else if (cstr == "!SC_DIS10A") return "scientist/c1a0_sci_dis10a";
	else if (cstr == "!SC_DIS11A") return "scientist/c1a0_sci_dis11a";
	else if (cstr == "!SC_DIS12A") return "scientist/c1a0_sci_dis12a";
	else if (cstr == "!SC_DIS13A") return "scientist/c1a0_sci_dis13a";
	else if (cstr == "!SC_DIS14A") return "scientist/c1a0_sci_dis14a";
	else if (cstr == "!SC_DIS15A") return "scientist/c1a0_sci_dis15a";
	else if (cstr == "!SC_DIS16A") return "scientist/c1a0_sci_dis16a";
	else if (cstr == "!SC_DIS17A") return "scientist/c1a0_sci_dis17a";
	else if (cstr == "!SC_GETAWAY") return "scientist/c1a0_sci_getaway";
	else if (cstr == "!SC_GMORN") return "scientist/c1a0_sci_gm";
	else if (cstr == "!SC_BIGDAY") return "scientist/c1a0_sci_bigday";
	else if (cstr == "!SC_SAMPLE") return "scientist/c1a0_sci_samp";
	else if (cstr == "!SC_NOTTHAT") return "scientist/c1a0_sci_desk";
	else if (cstr == "!SC_LOCK1A") return "scientist/c1a0_sci_lock1a";
	else if (cstr == "!SC_LOCK2A") return "scientist/c1a0_sci_lock2a";
	else if (cstr == "!SC_LOCK3A") return "scientist/c1a0_sci_lock3a";
	else if (cstr == "!SC_LOCK4A") return "scientist/c1a0_sci_lock4a";
	else if (cstr == "!SC_LOCK5A") return "scientist/c1a0_sci_lock5a";
	else if (cstr == "!SC_LOCK6A") return "scientist/c1a0_sci_lock6a";
	else if (cstr == "!SC_LOCK7A") return "scientist/c1a0_sci_lock7a";
	else if (cstr == "!SC_LOCK8A") return "scientist/c1a0_sci_lock8a";
	else if (cstr == "!SC_LOCK9A") return "scientist/c1a0_sci_lock9a";
	else if (cstr == "!SC_CRIT1A") return "scientist/c1a0_sci_crit1a";
	else if (cstr == "!SC_CRIT2A") return "scientist/c1a0_sci_crit2a";
	else if (cstr == "!SC_CRIT3A") return "scientist/c1a0_sci_crit3a";
	else if (cstr == "!SC_CTRL1A") return "scientist/c1a0_sci_ctrl1a";
	else if (cstr == "!SC_CTRL2A") return "scientist/c1a0_sci_ctrl2a";
	else if (cstr == "!SC_CTRL3A") return "scientist/c1a0_sci_ctrl3a";
	else if (cstr == "!SC_CTRL4A") return "scientist/c1a0_sci_ctrl4a";
	else if (cstr == "!SC_CONSOLE1A") return "scientist/c1a1_sci_1scan";
	else if (cstr == "!SC_CONSOLE2A") return "scientist/c1a1_sci_2scan";
	else if (cstr == "!SC_CONSOLE3A") return "scientist/c1a1_sci_3scan";
	else if (cstr == "!SC_CONSOLE4A") return "scientist/c1a1_sci_4scan";
	else if (cstr == "!SC_CONSOLE5A") return "scientist/c1a1_sci_5scan";
	else if (cstr == "!SC_CONSOLERPT") return "scientist/c1a1_sci_scanrpt";
	else if (cstr == "!SC_ZOMBIE1A") return "scientist/c1a2_sci_1zomb";
	else if (cstr == "!SC_ZOMBIE3A") return "scientist/c1a2_sci_3zomb";
	else if (cstr == "!SC_ZOMBIE5A") return "scientist/c1a2_sci_5zomb";
	else if (cstr == "!SC_ZOMBIE6A") return "scientist/c1a2_sci_6zomb";
	else if (cstr == "!SC_DANGLING") return "scientist/c1a2_sci_dangling";
	else if (cstr == "!SC_DARKROOM") return "scientist/c1a2_sci_darkroom";
	else if (cstr == "!SC_ELEVATOR") return "scientist/c1a2_sci_elevator";
	else if (cstr == "!SC_LOUNGE") return "scientist/c1a2_sci_lounge";
	else if (cstr == "!SC_TRANSMISSION") return "scientist/c1a2_sci_transm";
	else if (cstr == "!SC_1MAN") return "scientist/c1a3_sci_1man";
	else if (cstr == "!SC_ATLAST") return "scientist/c1a3_sci_atlast";
	else if (cstr == "!SC_RESCUED") return "scientist/c1a3_sci_rescued";
	else if (cstr == "!SC_SILO1A") return "scientist/c1a3_sci_silo1a";
	else if (cstr == "!SC_SILO2A") return "scientist/c1a3_sci_silo2a";
	else if (cstr == "!SC_TEAM") return "scientist/c1a3_sci_team";
	else if (cstr == "!SC_THANKGOD") return "scientist/c1a3_sci_thankgod";
	else if (cstr == "!SC_TRAINEND") return "scientist/c1a4_sci_trainend";
	else if (cstr == "!SC_ROCKET") return "scientist/c1a4_sci_rocket";
	else if (cstr == "!SC_BLIND") return "scientist/c1a4_sci_blind";
	else if (cstr == "!SC_POWEROFF") return "scientist/c1a4_sci_pwroff";
	else if (cstr == "!SC_POWERON") return "scientist/c1a4_sci_pwr";
	else if (cstr == "!SC_GENER") return "scientist/c1a4_sci_gener";
	else if (cstr == "!SC_TRUST") return "scientist/c1a4_sci_trust";
	else if (cstr == "!SC_TENT") return "scientist/c1a4_sci_tent";
	else if (cstr == "!SC_ICKY") return "scientist/c2a3_sci_icky";
	else if (cstr == "!SC_TRACK") return "scientist/c2a3_sci_track";
	else if (cstr == "!SC_ARG1A") return "scientist/c2a4_sci_arg2a";
	else if (cstr == "!SC_ARG2A") return "scientist/c2a4_sci_arg4a";
	else if (cstr == "!SC_TAU2A") return "scientist/c2a4_sci_2tau";
	else if (cstr == "!SC_TAU4A") return "scientist/c2a4_sci_4tau";
	else if (cstr == "!SC_1PSURG") return "scientist/c2a4_sci_scanner";
	else if (cstr == "!SC_2PSURG") return "scientist/c2a4_sci_sugicaloff";
	else if (cstr == "!SC_3PSURG") return "scientist/c2a4_sci_surgury";
	else if (cstr == "!SC_ALLDIE") return "scientist/c2a4_sci_alldie";
	else if (cstr == "!SC_LETOUT") return "scientist/c2a4_sci_letout";
	else if (cstr == "!SC_BOOBIE") return "scientist/c2a5_sci_boobie";
	else if (cstr == "!SC_LEBUZ") return "scientist/c2a5_sci_lebuz";
	else if (cstr == "!SC_STRAWS") return "scientist/c3a2_sci_straws";
	else if (cstr == "!SC_GLUON2A") return "scientist/c3a2_sci_2glu";
	else if (cstr == "!SC_FLOOD") return "scientist/c3a2_sci_flood";
	else if (cstr == "!SC_LINGER") return "scientist/c3a2_sci_linger";
	else if (cstr == "!SC_SURVEY1A") return "scientist/c3a2_sci_1surv";
	else if (cstr == "!SC_SURVEY3A") return "scientist/c3a2_sci_3surv";
	else if (cstr == "!SC_SURVEY5A") return "scientist/c3a2_sci_5surv";
	else if (cstr == "!SC_SURVEY7A") return "scientist/c3a2_sci_7surv";
	else if (cstr == "!SC_LJUMP") return "scientist/c3a2_sci_ljump";
	else if (cstr == "!SC_UPHERE") return "scientist/c3a2_sci_uphere";
	else if (cstr == "!SC_PORTAL") return "scientist/c3a2_sci_portal";
	else if (cstr == "!SC_PORTOPEN") return "scientist/c3a2_sci_portopen";
	else if (cstr == "!SC_POSITION") return "scientist/c3a2_sci_position";
	else if (cstr == "!SC_FOREVER") return "scientist/c3a2_sci_forever";
	else if (cstr == "!SC_NOTYET") return "scientist/c3a2_sci_notyet";
	else if (cstr == "!SC_FOOL") return "scientist/c3a2_sci_fool";
	else if (cstr == "!SC_LETYOUIN") return "scientist/letyouin";
	else if (cstr == "!SC_OVERHERE") return "scientist/overhere";
	else if (cstr == "!WILD0") return "ambience/";
	else if (cstr == "!WILD1") return "ambience/bee1";
	else if (cstr == "!WILD2") return "ambience/bee2";
	else if (cstr == "!WILD3") return "ambience/hawk1";
	else if (cstr == "!WILD4") return "ambience/hawk1";
	else if (cstr == "!WILD5") return "ambience/";
	else if (cstr == "!WILD6") return "ambience/bee1";
	else if (cstr == "!WILD7") return "ambience/bee1";
	else if (cstr == "!WILD8") return "ambience/quail1";
	else if (cstr == "!WILD9") return "ambience/des_wind1";
	else if (cstr == "!WILD10") return "ambience/des_wind2";
	else if (cstr == "!WILD11") return "ambience/des_wind3";
	else if (cstr == "!WILD9") return "ambience/des_wind1";
	else if (cstr == "!WILD10") return "ambience/des_wind2";
	else if (cstr == "!WILD11") return "ambience/des_wind3";
	else if (cstr == "!WILD12") return "ambience/wren1";
	else if (cstr == "!ROCKET0") return "ambience/steamburst1";
	else if (cstr == "!ROCKET1") return "ambience/steamburst1";
	else if (cstr == "!ROCKET2") return "ambience/steamburst1";
	else if (cstr == "!ROCKET3") return "ambience/rocket_groan1";
	else if (cstr == "!ROCKET4") return "ambience/rocket_groan2";
	else if (cstr == "!ROCKET5") return "ambience/rocket_groan3";
	else if (cstr == "!ROCKET6") return "ambience/rocket_groan4";
	else if (cstr == "!FAR_WAR0") return "ambience/";
	else if (cstr == "!FAR_WAR1") return "ambience/";
	else if (cstr == "!FAR_WAR2") return "ambience/";
	else if (cstr == "!FAR_WAR3") return "ambience/";
	else if (cstr == "!FAR_WAR4") return "ambience/";
	else if (cstr == "!FAR_WAR5") return "ambience/";
	else if (cstr == "!FAR_WAR6") return "ambience/";
	else if (cstr == "!FAR_WAR7") return "ambience/";
	else if (cstr == "!FAR_WAR8") return "ambience/";
	else if (cstr == "!FAR_WAR9") return "ambience/";
	else if (cstr == "!FAR_WAR10") return "ambience/";
	else if (cstr == "!FAR_WAR11") return "ambience/";
	else if (cstr == "!FAR_WAR12") return "ambience/";
	else if (cstr == "!FAR_WAR13") return "ambience/";
	else if (cstr == "!FAR_WAR14") return "ambience/";
	else if (cstr == "!FAR_WAR15") return "ambience/";
	else if (cstr == "!FAR_WAR16") return "ambience/";
	else if (cstr == "!NEAR_WAR0") return "ambience/";
	else if (cstr == "!NEAR_WAR1") return "ambience/";
	else if (cstr == "!NEAR_WAR2") return "ambience/";
	else if (cstr == "!NEAR_WAR3") return "ambience/";
	else if (cstr == "!NEAR_WAR4") return "ambience/";
	else if (cstr == "!NEAR_WAR5") return "ambience/";
	else if (cstr == "!NEAR_WAR6") return "ambience/";
	else if (cstr == "!NEAR_WAR7") return "ambience/distantmortar1";
	else if (cstr == "!NEAR_WAR8") return "ambience/";
	else if (cstr == "!NEAR_WAR9") return "ambience/";
	else if (cstr == "!NEAR_WAR10") return "agrunt/";
	else if (cstr == "!NEAR_WAR11") return "ambience/distantmortar1";
	else if (cstr == "!NEAR_WAR12") return "ambience/";
	else if (cstr == "!SLV_IDLE0") return "aslave/slv_word1";
	else if (cstr == "!SLV_IDLE1") return "aslave/slv_word2";
	else if (cstr == "!SLV_IDLE2") return "aslave/slv_word3";
	else if (cstr == "!SLV_IDLE3") return "aslave/slv_word4";
	else if (cstr == "!SLV_IDLE4") return "aslave/slv_word2";
	else if (cstr == "!SLV_IDLE5") return "aslave/slv_word6";
	else if (cstr == "!SLV_IDLE6") return "aslave/slv_word7";
	else if (cstr == "!SLV_IDLE7") return "aslave/slv_word8";
	else if (cstr == "!SLV_IDLE8") return "aslave/slv_word1";
	else if (cstr == "!SLV_IDLE9") return "aslave/slv_word3";
	else if (cstr == "!SLV_IDLE10") return "aslave/slv_word7";
	else if (cstr == "!SLV_ALERT0") return "aslave/";
	else if (cstr == "!SLV_ALERT1") return "aslave/";
	else if (cstr == "!SLV_ALERT2") return "aslave/";
	else if (cstr == "!SLV_ALERT3") return "aslave/";
	else if (cstr == "!SLV_ALERT4") return "aslave/";
	else if (cstr == "!SLV_ALERT5") return "aslave/";
	else if (cstr == "!HOLO_3JUMPS") return "holo/tr_holo_3jumps";
	else if (cstr == "!HOLO_BREAKBOX") return "holo/tr_holo_breakbox";
	else if (cstr == "!HOLO_BREATH") return "holo/tr_holo_breath";
	else if (cstr == "!HOLO_BUTTON") return "holo/tr_holo_button";
	else if (cstr == "!HOLO_CHARGER") return "holo/tr_holo_charger";
	else if (cstr == "!HOLO_COMMENCING") return "holo/tr_holo_commencing";
	else if (cstr == "!HOLO_CONGRATS") return "holo/tr_holo_congrats";
	else if (cstr == "!HOLO_DONE") return "holo/tr_holo_done";
	else if (cstr == "!HOLO_DROWN") return "holo/tr_holo_drown";
	else if (cstr == "!HOLO_DUCK") return "holo/tr_holo_duck";
	else if (cstr == "!HOLO_FALLSHORT") return "holo/tr_holo_fallshort";
	else if (cstr == "!HOLO_FANTASTIC") return "holo/tr_holo_fantastic";
	else if (cstr == "!HOLO_FLASHLIGHT") return "holo/tr_holo_flashlight";
	else if (cstr == "!HOLO_GREATWORK") return "holo/tr_holo_greatwork";
	else if (cstr == "!HOLO_GRENADE") return "holo/tr_holo_grenade";
	else if (cstr == "!HOLO_HITALL") return "holo/tr_holo_hitall";
	else if (cstr == "!HOLO_INJURY") return "holo/tr_holo_injury";
	else if (cstr == "!HOLO_INTRO") return "holo/tr_holo_intro";
	else if (cstr == "!HOLO_JDUCK") return "holo/tr_holo_jduck";
	else if (cstr == "!HOLO_JUMP") return "holo/tr_holo_jump";
	else if (cstr == "!HOLO_JUMPDOWN") return "holo/tr_holo_jumpdown";
	else if (cstr == "!HOLO_JUMPGAP") return "holo/tr_holo_jumpgap";
	else if (cstr == "!HOLO_KEEPTRYING") return "holo/tr_holo_keeptrying";
	else if (cstr == "!HOLO_LADDER") return "holo/tr_holo_ladder";
	else if (cstr == "!HOLO_LEADGUARD") return "holo/tr_holo_leadguard";
	else if (cstr == "!HOLO_LIGHTOFF") return "holo/tr_holo_lightoff";
	else if (cstr == "!HOLO_LONGJUMP") return "holo/tr_holo_longjump";
	else if (cstr == "!HOLO_MEDKIT") return "holo/tr_holo_medkit";
	else if (cstr == "!HOLO_MOVE") return "holo/tr_holo_move";
	else if (cstr == "!HOLO_NICEJOB") return "holo/tr_holo_nicejob";
	else if (cstr == "!HOLO_PIPEDUCK") return "holo/tr_holo_pipeduck";
	else if (cstr == "!HOLO_PULLBOX") return "holo/tr_holo_pullbox";
	else if (cstr == "!HOLO_PUSHBOX") return "holo/tr_holo_pushbox";
	else if (cstr == "!HOLO_RADIATION") return "holo/tr_holo_radiation";
	else if (cstr == "!HOLO_RETRY") return "holo/tr_holo_retry";
	else if (cstr == "!HOLO_RUNSTART") return "holo/tr_holo_runstart";
	else if (cstr == "!HOLO_SPINBRIDGE") return "holo/tr_holo_spinbridge";
	else if (cstr == "!HOLO_STARTLIFT") return "holo/tr_holo_startlift";
	else if (cstr == "!HOLO_STEAM") return "holo/tr_holo_steam";
	else if (cstr == "!HOLO_TARGET") return "holo/tr_holo_target";
	else if (cstr == "!HOLO_TRYAGAIN") return "holo/tr_holo_tryagain";
	else if (cstr == "!HOLO_USETRAIN") return "holo/tr_holo_usetrain";
	else if (cstr == "!GM_1MUMBLE") return "gman/gman_mumble1";
	else if (cstr == "!GM_2MUMBLE") return "gman/gman_mumble2";
	else if (cstr == "!GM_3MUMBLE") return "gman/gman_mumble3";
	else if (cstr == "!GM_4MUMBLE") return "gman/gman_mumble4";
	else if (cstr == "!GM_5MUMBLE") return "gman/gman_mumble5";
	else if (cstr == "!GM_6MUMBLE") return "gman/gman_mumble6";
	else if (cstr == "!GM_SUIT") return "gman/gman_suit";
	else if (cstr == "!GM_NASTY") return "gman/gman_nasty";
	else if (cstr == "!GM_POTENTIAL") return "gman/gman_potential";
	else if (cstr == "!GM_STEPIN") return "gman/gman_stepin";
	else if (cstr == "!GM_OTHERWISE") return "gman/gman_otherwise";
	else if (cstr == "!GM_1CHOOSE") return "gman/gman_choose1";
	else if (cstr == "!GM_2CHOOSE") return "gman/gman_choose2";
	else if (cstr == "!GM_WISE") return "gman/gman_wise";
	else if (cstr == "!GM_REGRET") return "gman/gman_noreg";
	else if (cstr == "!GM_WONTWORK") return "gman/gman_nowork";
	else if (cstr == "BA_1SAT") return "barney/c3a1_ba_1sat";
	else if (cstr == "!SCI_2SAT") return "scientist/c3a1_sci_2sat";
	else if (cstr == "!BA_3SAT") return "barney/c3a1_ba_3sat";
	else if (cstr == "!SCI_4SAT") return "scientist/c3a1_sci_4sat";
	else if (cstr == "!BA_5SAT") return "barney/c3a1_ba_5sat";
	else if (cstr == "!SCI_6SAT") return "scientist/c3a1_sci_6sat";
	else if (cstr == "!BA_6SAT") return "barney/c1a4_ba_octo4";
	else if (cstr == "!BA_7SAT") return "barney/c1a4_ba_octo3";
	else if (cstr == "!SCI_7SAT") return "scientist/scream07";
	else if (cstr == "!SCI_8SAT") return "scientist/scream04";
	else if (speaker_sound(cstr) != "NOSPEAK") return speaker_sound(cstr);
	else return "NOLINK";
};

string (string cstr) speaker_sound =
{
	self.is_speaker = #TRUE;
	if (cstr == "!C1A0_START") return "dadeda vox_login ";
	else if (cstr == "!C1A0_0") return "dadeda ( e95 ) agent ( t0 ) coomer ( t0 ) , report to ( e70 ) topside tactical operations center ( e100 ) ";
	else if (cstr == "!C1A0_1") return "dadeda inspection team , to ( e70 ) radioactive materials handling bay ( e100 ) ";
	else if (cstr == "!C1A0_2") return "dadeda ( e95 ) agent sixteen , report to ( e70 ) administration sub level two ( e100 ) ";
	else if (cstr == "!C1A0_3") return "doop ( e95 ) doctor johnson , please call observation tank one ( e100 ) ";
	else if (cstr == "!C1A0_4") return "doop ( e95 p96 ) doctor west ( t0 ) , please report to ( e70 ) lambda ( s0 ) reactor complex ( e100 ) ";
	else if (cstr == "!C1A0_5") return "doop ( e95 ) doctor cross , call seven two nine please ( e100 ) ";
	else if (cstr == "!C1A0_6") return "doop ( e95 ) sargeant ( s0 ) bailey ( s0 ) , to ( e70 ) topside checkpoint bravo ( e100 ) ";
	else if (cstr == "!C1A0_7") return "dadeda ( e95 ) cryogenic safety crew , report status at eleven hundred please ( e100 ) ";
	else if (cstr == "!C1A0_8") return "dadeda ( e95 ) coded message for captain black , command and ( s0 e100 t0 ) communication center ( e100 ) ";
	else if (cstr == "!C1A0_9") return "dadeda ( e95 p102 ) sector c ( e100 ) science personnel , report to ( e70 ) anomalous materials test lab ( e100 ) ";
	else if (cstr == "!C1A0_10") return "doop ( e95 p103 ) doctor freeman , ( e95 ) to ( e70 ) anomalous materials test lab immediately ( e100 ) ";
	else if (cstr == "!C1A0_11") return "bloop ( e95 p98 ) attention. experimental propulsion lab test fire in ( s0 e100 t0 ) ninety minutes ( e100 ) ";
	else if (cstr == "!C1A0_12") return "bloop ( e95 p98 ) hydro plant now ( s0 e100 t0 ) operating at ( s0 e100 t0 ) sixty percent ( e100 ) ";
	else if (cstr == "!C1A0_13") return "bloop ( e95 ) black mesa topside temperature is ninety three degrees ( e100 ) ";
	else if (cstr == "!C1A0_14") return "bloop ( e95 ) launch officer reports , alpha satellite deploy is ( t0 s0 e100 ) nominal ( e100 ) ";
	else if (cstr == "!C1A0_15") return "bloop ( e95 ) doctor birdwell reports ( e95 ) superconducting interchange is ( t0 s0 e100 ) activated ( e100 ) ";
	else if (cstr == "!C1A0_16") return "bloop ( e95 p104 ) attention. report any security violation , to ( e70 ) administration sub level one ( e100 ) ";
	else if (cstr == "!C1A0_17") return "bloop ( e95 ) attention. service personnel please clear helicopter hangar one ( e100 ) ";
	else if (cstr == "!C1A0_18") return "bloop ( e95 ) shield inspection ( s0 ) crew reports primary reactor nominal ( e100 ) ";
	else if (cstr == "!C1A0_19") return "bloop ( e95 p98 ) transportation control reports all systems on time ( e100 ) ";
	else if (cstr == "!C1A0_20") return "dadeda ( e95 ) doctor victor , report to ( e70 ) supercooled ( e100 ) laser lab please ( e100 ) ";
	else if (cstr == "!C1A0_21") return "dadeda ( e95 p104 ) sargeant guthrie , report to ( e70 ) topside motorpool immediately ( e100 ) ";
	else if (cstr == "!C1A0_22") return "deeoo ( e95 p98 ) uranium shipment inspection team , to ( e100 ) sector d ( e100 ) ";
	else if (cstr == "!C1A1_0") return "bizwarn bizwarn bizwarn warning , high energy detonation detected in materials lab ";
	else if (cstr == "!C1A1_1") return "buzwarn buzwarn attention , security personnel to sector c immediately ";
	else if (cstr == "!C1A1_2") return "buzwarn buzwarn ( p102 ) warning , unauthorized biological forms detected in sector c ";
	else if (cstr == "!C1A1_3") return "buzwarn buzwarn ( p102 ) warning , unauthorized biological forms detected in coolant maintenance area ";
	else if (cstr == "!C1A1_4") return "bizwarn bizwarn bizwarn any damage control team to sector c immediately ";
	else if (cstr == "!C1A1_5") return "buzwarn buzwarn warning , sector c elevator failure. do not use. ";
	else if (cstr == "!C1A1_6") return "bizwarn bizwarn bizwarn ( p102 ) biohazard warning in sector b and c ( p104 ) ";
	else if (cstr == "!C1A1_7") return "buzwarn buzwarn attention. sector c science personnel evacuate area immediately ";
	else if (cstr == "!C1A1_8") return "buzwarn buzwarn warning , flooding detected on sub level three , sector b ";
	else if (cstr == "!C1A1_9") return "bizwarn bizwarn bizwarn warning , anomalous energy field detected in administration center ";
	else if (cstr == "!C1A1_10") return "deeoo deeoo ( p104 ) attention. any sector c science personnel , please report status ";
	else if (cstr == "!C1A1_11") return "deeoo deeoo ( p104 ) attention. sector c science personnel please report status immediately ";
	else if (cstr == "!C1A2_0") return "deeoo ( e95 ) emergency cleanup team to ( e70 ) biological waste processing plant ( e100 ) ";
	else if (cstr == "!C1A2_1") return "buzwarn buzwarn attention , administration personnel evacuate sector d immediately ";
	else if (cstr == "!C1A2_2") return "deeoo deeoo attention , security personnel to sector d ";
	else if (cstr == "!C1A2_3") return "deeoo ( e95 ) service team , check elevator one ( s0 e100 t0 ) , ( p100 ) sector c ( e100 ) ";
	else if (cstr == "!C1A2_4") return "buzwarn buzwarn warning , unauthorized biological forms detected in ventillation system ";
	else if (cstr == "!C1A2_5") return "deeoo ( e95 p103 ) lieutenant backman and cleanup team , to ( e70 ) sub level three ( e100 ) ";
	else if (cstr == "!C1A2_6") return "bizwarn bizwarn bizwarn danger , turret defense systems activated , sector d ";
	else if (cstr == "!C1A2_7") return "deeoo deeoo security officer reports men down in sector d , medical help required ";
	else if (cstr == "!C1A2_8") return "bizwarn bizwarn bizwarn extreme danger , all turret defense systems activated , sector d ";
	else if (cstr == "!C1A2_9") return "deeoo ( e95 ) turret repair personnel , to ( e70 ) high security materials storage area ( e100 ) ";
	else if (cstr == "!C1A2_10") return "deeoo deeoo attention. electric shock hazard detected in administration center ";
	else if (cstr == "!C1A2_11") return "buzwarn buzwarn. security officer reports medical emergency , administration center ";
	else if (cstr == "!C1A3_0") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention. all science personnel report topside for immediate questioning ";
	else if (cstr == "!C1A3_1") return "( p120 ) buzwarn buzwarn ( e95 p100 ) all personnel evacuate high security materials storage facility ";
	else if (cstr == "!C1A3_2") return "bizwarn bizwarn ( e95 p98 ) emergency uranium containment team , to ( e100 ) sector d ( e100 ) ";
	else if (cstr == "!C1A3_3") return "deeoo ( e95 ) turret maintenance team , to ( e70 ) central command and communication ( s0 ) center ( e100 ) ";
	else if (cstr == "!C1A3_4") return "( p130 ) buzwarn buzwarn ( p98 e95 ) military personnel , prosecute kilo india lima with extreme force ";
	else if (cstr == "!C1A3_5") return "( p130 ) bizwarn bizwarn bizwarn ( e95 p95 ) attention. this announcement system now ( e100 ) under military command ";
	else if (cstr == "!C1A3_6") return "( p130 ) buzwarn buzwarn ( p98 e95 ) search and destroy force bravo , reports secondary objective terminated ";
	else if (cstr == "!C1A3_7") return "( p130 ) buzwarn buzwarn ( p98 e95 ) bravo force reports hotel sierra mike facility is secured ";
	else if (cstr == "!C1A3_8") return "( p130 ) bizwarn bizwarn ( p100 t15 e95 ) attention. all military personnel , atomic biological chemical alert ";
	else if (cstr == "!C1A3_9") return "( p130 ) bizwarn bizwarn ( p100 t15 e95 ) attention. all military personnel , extreme atomic biological chemical alert ";
	else if (cstr == "!C1A3_10") return "( p110 ) bizwarn bizwarn bizwarn ( e95 p95 ) attention. black mesa announcement system now ( e100 ) under military command ";
	else if (cstr == "!C1A3_warn") return "( p120 ) buzwarn buzwarn ( p100 t15 ) attention. security lockout alert. security door will engage. ";
	else if (cstr == "!C1A3_lock") return "( p120 ) bizwarn bizwarn ( p98 t15 ) security door engaged , five , buzwarn ( p130 ) , four , buzwarn ( p130 ) , three , buzwarn ( p130 ) , two , buzwarn ( p130 ) , one , buzwarn ( p130 ) , lockout activated ";
	else if (cstr == "!C1A4_0") return "buzwarn buzwarn. attention. experimental rocket test fire disengaged. ";
	else if (cstr == "!C1A4_1") return "deeoo ( e95 ) repair crew report to ( e70 ) track control , sector e ( e100 ) ";
	else if (cstr == "!C1A4_2") return "deeoo ( e95 ) maintenance team blue ( p100 t0 s0 e100 ) , check heat exchange coolant level ( e100 ) ";
	else if (cstr == "!C1A4_3") return "deeoo ( e95 ) maintenance team green , check voltage ( e100 ) on cable seven two nine ( e100 ) ";
	else if (cstr == "!C1A4_4") return "( p130 ) buzwarn buzwarn ( p98 e95 ) medical team to materials storage facility , team bravo reports men down ";
	else if (cstr == "!C1A4_5") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alpha force move out , science personnel resistance extreme ";
	else if (cstr == "!C1A4_6") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention. all black mesa security personnel wanted for immediate questioning ";
	else if (cstr == "!C1A4_7") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention. gordon freeman report to military personnel for immediate security check ";
	else if (cstr == "!C1A4_8") return "buzwarn buzwarn ( p102 ) warning , hostile biological forms detected in track control sector e ";
	else if (cstr == "!FUEL_OFF") return "fuel and power must be engaged to activate rocket test fire ";
	else if (cstr == "!C2A1_0") return "buzwarn buzwarn. warning. track power failure. check lower level power plant. ";
	else if (cstr == "!C2A1_1") return "deeoo ( e95 ) maintenance team yellow , please ( s0 e100 ) service relay three hundred ninety four ( e100 ) ";
	else if (cstr == "!C2A1_2") return "( p130 ) dadeda ( p98 e95 ) attention. gordon freeman report to military personnel for immediate security check ";
	else if (cstr == "!C2A1_3") return "( p130 ) buzwarn buzwarn ( p98 e95 ) delta team reports launch control secured ";
	else if (cstr == "!C2A1_4") return "bizwarn bizwarn bizwarn danger , turret defense systems activated , silo e ";
	else if (cstr == "!C2A1_5") return "deeoo sector e track control please report status ";
	else if (cstr == "!C2A1_6") return "( p130 ) buzwarn buzwarn ( p98 e95 ) echo force reports perimeter breach , sector e ";
	else if (cstr == "!C2A1_7") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention , search and destroy force go to code three. eliminate all biological forms. ";
	else if (cstr == "!C2A1_8") return "bizwarn bizwarn danger , unauthorized detonation detected in experimental propulsion lab ";
	else if (cstr == "!POWER_OFF") return "buzwarn main power is not on ";
	else if (cstr == "!POWER_ON") return "deeoo main power is on ";
	else if (cstr == "!C2A2_0") return "buzwarn buzwarn. attention , clear silo e launch area immediately ";
	else if (cstr == "!C2A2_1") return "deeoo ( e95 ) containment inspection team , to ( e70 ) advanced biological research lab ( e100 ) ";
	else if (cstr == "!C2A2_2") return "( p130 ) buzwarn buzwarn ( p98 e95 ) medical team to sector e , echo team has men down ";
	else if (cstr == "!C2A2_3") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert , military personnel authorized to prosecute gordon freeman with extreme force ";
	else if (cstr == "!C2A2_3") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert , military personnel , you are authorized to shoot the renegade on sight ";
	else if (cstr == "!C2A2_4") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert , squad in silo e , freeman may be operating inside your perimeter ";
	else if (cstr == "!C2A2_5") return "deeoo deeoo launch control train activity detected ";
	else if (cstr == "!C2A2_6") return "( p130 ) buzwarn buzwarn ( p98 e95 ) medical team to sector e , echo team squad failed to reach checkpoint ";
	else if (cstr == "!C2A2_7") return "deeoo deeoo satellite rocket loading bay reports status green ";
	else if (cstr == "!C2A2_launch") return "( p50 ) deeoo deeoo deeoo ( p100 ) satellite launch system activated. five deeoo ( p50 ) four deeoo ( p51 ) three deeoo ( p52 ) two deeoo ( p53 ) one deeoo ( p54 ) launch is go ";
	else if (cstr == "!C2A4_0") return "buzwarn buzwarn warning. emergency containment system activated ";
	else if (cstr == "!C2A4_1") return "bizwarn bizwarn. alert. biological containment breach detected ";
	else if (cstr == "!C2A4_2") return "bizwarn bizwarn. warning , biological sterilization system activated ";
	else if (cstr == "!C2A4_3") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention , hostile alien military force detected , advanced biological research lab ";
	else if (cstr == "!C2A4_4") return "( p130 ) buzwarn buzwarn ( p98 e95 ) search and destroy force reports back up required , engaged with extreme resistance ";
	else if (cstr == "!C2A4_5") return "( p130 ) buzwarn buzwarn ( p98 e95 ) topside containment force alert , hostile alien military force detected ";
	else if (cstr == "!C2A4_6") return "deeoo deeoo high power laser status is green ";
	else if (cstr == "!C2A4_7") return "bizwarn bizwarn , alien containment system failure , use sterilization chamber ";
	else if (cstr == "!C2A4_8") return "bizwarn bizwarn attention. all topside military personnel clear helicopter hangar four ";
	else if (cstr == "!C2A4_9") return "bizwarn bizwarn , hostile alien breach , topside checkpoint alpha , checkpoint delta ";
	else if (cstr == "!C2A4_10") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert topside containment force , use any force to prosecute gordon freeman. you are authorized to shoot on sight. ";
	else if (cstr == "!C2A4_11") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert topside containment force , freeman may approach your perimeter ";
	else if (cstr == "!C2A4_12") return "( p105 ) gordon , all science personnel will be terminated until you surrender ";
	else if (cstr == "!C2A4_ster") return "bizwarn bizwarn sterilization system activated ";
	else if (cstr == "!C3A1_0") return "buzwarn buzwarn warning primary antenna failure detected ";
	else if (cstr == "!C3A1_1") return "( p130 ) buzwarn buzwarn ( p98 e95 ) clear topside motorpool for emergency medical helicopter ";
	else if (cstr == "!C3A1_2") return "( p130 ) buzwarn buzwarn ( p98 e95 ) warning , topside armory security bypass detected ";
	else if (cstr == "!C3A1_3") return "bizwarn bizwarn warning , radiation leak detected in primary antenna area ";
	else if (cstr == "!C3A1_4") return "( p130 ) buzwarn buzwarn ( p98 e95 ) search and destroy force kilo , central command reports hostile alien force inside perimeter ";
	else if (cstr == "!C3A1_5") return "( p130 ) buzwarn buzwarn ( p98 e95 ) message for gordon freeman , you will not escape this time ";
	else if (cstr == "!C3A1_6") return "( p130 ) buzwarn buzwarn ( p98 e95 ) attention all units , renegade freeman is now your primary target ";
	else if (cstr == "!C3A1_7") return "( p130 ) buzwarn buzwarn ( p98 e95 ) alert remaining containment force , freeman may have experimental weapon ";
	else if (cstr == "!C3A1_8") return "( p130 ) buzwarn buzwarn ( p98 e95 ) all personnel evacuate lambda complex , extreme dimensional malfunction detected ";
	else if (cstr == "!C3A1_9") return "bizwarn bizwarn fire control team to topside armory , checkpoint delta , topside hydro plant ";
	else if (cstr == "!C3A2_0") return "bizwarn bizwarn warning , cross dimensional power field activity detected ";
	else if (cstr == "!C3A2_1") return "bizwarn bizwarn warning , unauthorized biological force detected in cross dimensional power field ";
	else if (cstr == "!C3A2_2") return "( p130 ) buzwarn buzwarn ( p98 e95 ) all personnel evacuate lambda complex , extreme dimensional malfunction detected ";
	else if (cstr == "!C3A2_3") return "bizwarn bizwarn bizwarn , unauthorized activity detected in main reactor core ";
	else if (cstr == "!C3A2_4") return "bizwarn bizwarn , danger , high energy exchange detected in radioactive materials handling bay ";
	else if (cstr == "!C3A2_5") return "bizwarn bizwarn , biological force detected in primary coolant system ";
	else if (cstr == "!C3A2_6") return "( p120 ) bizwarn bizwarn , ( p100 ) lambda complex reports dimensional contamination ";
	else if (cstr == "!C3A2_7") return "bizwarn bizwarn , lambda complex reports dimensional containment system failure ";
	else if (cstr == "!C3A2_target") return "bloop ( p150 ) bloop ( p150 ) satellite target system , engaged ";
	else if (cstr == "!C3A2_portal") return "bizwarn ( p80 ) bizwarn ( p80 ) bizwarn ( p80 ) warning , cross ( e80 ) dimensional portal device power level is one hundred twenty percent ";
	else if (cstr == "!C3A2_core") return "bizwarn bizwarn bizwarn , attention lambda complex personnel , primary core activated ";
	else if (cstr == "!CTR0") return "zero ";
	else if (cstr == "!CTR1") return "one second ";
	else if (cstr == "!CTR2") return "two ";
	else if (cstr == "!CTR3") return "three seconds ";
	else if (cstr == "!CTR4") return "four ";
	else if (cstr == "!CTR5") return "five seconds remaining ";
	else if (cstr == "!CTR6") return "six ";
	else if (cstr == "!CTR7") return "seven ";
	else if (cstr == "!CTR8") return "eight ";
	else if (cstr == "!CTR9") return "nine ";
	else if (cstr == "!CTR10") return "ten seconds remaining ";
	else if (cstr == "!CTR11") return "eleven ";
	else if (cstr == "!CTR12") return "twelve ";
	else if (cstr == "!CTR13") return "thirteen ";
	else if (cstr == "!CTR14") return "fourteen ";
	else if (cstr == "!CTR15") return "fifteen seconds remaining ";
	else if (cstr == "!CTR16") return "sixteen ";
	else if (cstr == "!CTR17") return "seventeen ";
	else if (cstr == "!CTR18") return "eighteen ";
	else if (cstr == "!CTR19") return "nineteen ";
	else if (cstr == "!CTR20") return "twenty seconds remaining ";
	else if (cstr == "!NA0") return "access denied ";
	else if (cstr == "!NA1") return "access is denied ";
	else if (cstr == "!NA2") return "unauthorized access ";
	else if (cstr == "!NA3") return "illegal access ";
	else if (cstr == "!NA4") return "this door is locked ";
	else if (cstr == "!NA5") return "unauthorized access ";
	else if (cstr == "!NA6") return "entry forbidden ";
	else if (cstr == "!NA7") return "entry not permitted ";
	else if (cstr == "!NA8") return "no unauthorized personnel ";
	else if (cstr == "!NA9") return "you do not have access to this facility ";
	else if (cstr == "!NA10") return "( p102 ) sorry , you may not enter ";
	else if (cstr == "!NA11") return "( p102 ) sorry , this door is locked ";
	else if (cstr == "!NA12") return "( p102 ) please , move away from this area ";
	else if (cstr == "!NA13") return "( p102 ) please , move away from door ";
	else if (cstr == "!NA14") return "( p103 ) you will not get in ";
	else if (cstr == "!NA15") return "( p103 ) entry is not an option ";
	else if (cstr == "!NA16") return "( p104 ) will we do this all day ";
	else if (cstr == "!NA17") return "( p104 ) move on immediately ";
	else if (cstr == "!NA18") return "( p105 ) no , no , and no ( p80 ) ";
	else if (cstr == "!EA0") return "access granted ";
	else if (cstr == "!EA1") return "access permitted ";
	else if (cstr == "!EA2") return "entry granted ";
	else if (cstr == "!EA3") return "entry permitted ";
	else if (cstr == "!EA4") return "access authorized ";
	else if (cstr == "!EA5") return "entry is permitted ";
	else if (cstr == "!EA6") return "access authorized ";
	else if (cstr == "!EA7") return "access to facility , granted ";
	else if (cstr == "!EA8") return "access granted ";
	else if (cstr == "!ND0") return "security lock is engaged ";
	else if (cstr == "!ND1") return "secure area , no entry ";
	else if (cstr == "!ND2") return "security lockout , no entry ";
	else if (cstr == "!ND3") return "secure door , no entry ";
	else if (cstr == "!ND4") return "security system in force ";
	else if (cstr == "!ND5") return "security system armed , no entry ";
	else if (cstr == "!ND6") return "door is secured ";
	else if (cstr == "!ND7") return "illegal access , move away ";
	else if (cstr == "!ED0") return "security lock disengaged ";
	else if (cstr == "!ED1") return "security clear , proceed ";
	else if (cstr == "!ED2") return "security lockout , released ";
	else if (cstr == "!ED3") return "secure override accepted ";
	else if (cstr == "!ED4") return "security access acknowledged ";
	else if (cstr == "!ED5") return "security system disengaged ";
	else if (cstr == "!ED6") return "door security disengaged ";
	else if (cstr == "!NF0") return "emergency blast door activated ";
	else if (cstr == "!NF1") return "emergency blast shield activated ";
	else if (cstr == "!NF3") return "the blast containment shield is down ";
	else if (cstr == "!EF0") return "emergency blast door , open ";
	else if (cstr == "!EF1") return "emergency blast shield , deactivated ";
	else if (cstr == "!EF3") return "blast containment shield is , open ";
	else if (cstr == "!NFIRE0") return "fire containment door is down ";
	else if (cstr == "!EFIRE0") return "fire containment door , open ";
	else if (cstr == "!NCHEM0") return "chemical leak containment door activated ";
	else if (cstr == "!ECHEM0") return "chemical leak containment door , open ";
	else if (cstr == "!NRAD0") return "radiation containment door activated ";
	else if (cstr == "!ERAD0") return "radiation containment door , open ";
	else if (cstr == "!NCON0") return "emergency containment door engaged ";
	else if (cstr == "!ECON0") return "emergency containment door disengaged ";
	else if (cstr == "!NG0") return "sorry , this door is inoperative ";
	else if (cstr == "!NG1") return "sorry , door out of service ";
	else if (cstr == "!NG2") return "door damage detected , please call service personnel ";
	else if (cstr == "!NH0") return "no access , maintenance area ";
	else if (cstr == "!NH1") return "no personnel permitted in maintenance area ";
	else if (cstr == "!EH0") return "maintenance area access granted ";
	else if (cstr == "!EH1") return "maintenance area door open ";
	else if (cstr == "!T0") return "extreme hazard , defense system is armed in this zone ";
	else if (cstr == "!T1") return "hazard area , defense system activated ";
	else if (cstr == "!T2") return "danger , turret perimeter defense system armed ";
	else if (cstr == "!T3") return "extreme hazard , nearest defense system engaged ";
	else if (cstr == "!T4") return "danger , base defense turret system may power up ";
	else if (cstr == "!T5") return "danger , automatic defense system activated ";
	else if (cstr == "!WE0") return "warning , high voltage cable ";
	else if (cstr == "!WE1") return "warning , high power cable ";
	else if (cstr == "!WE2") return "warning , electric shock hazard ";
	else if (cstr == "!WE3") return "warning , severe electric shock hazard ";
	else if (cstr == "!DR0") return "danger , radiation leak detected ";
	else if (cstr == "!DR1") return "danger , radiation hazard detected ";
	else if (cstr == "!DR2") return "danger , high radiation level detected ";
	else if (cstr == "!DR3") return "danger , severe radiation hazard , evacuate area immediately ";
	else if (cstr == "!DR4") return "danger , safety violation , extreme radiation level detected ";
	else if (cstr == "!DC0") return "danger , chemical leak , area now a high health hazard ";
	else if (cstr == "!DC1") return "danger , chemical coolant leak , health hazard zone ";
	else if (cstr == "!DC2") return "danger , chemical containment breach , all personnel evacuate this area ";
	else if (cstr == "!DC3") return "danger , supercooled chemical leak ";
	else if (cstr == "!DC4") return "danger , supercooled helium leak ";
	else if (cstr == "!DB0") return "danger , liquid biohazard leak in immediate area ";
	else if (cstr == "!DB1") return "danger , coolant leak , severe biohazard now in this area ";
	else if (cstr == "!DB2") return "danger , liquid biohazard released , evacuate area ";
	else if (cstr == "!DB3") return "danger , biohazard detected in immediate area ";
	else if (cstr == "!TR_A") return "three , two , one , deeoo ( p110 ) ";
	else if (cstr == "!TR_B") return "deeoo ( p110 ) ( p102 t20 ) target system deactivated ";
	self.is_speaker = #FALSE;
	return "NOSPEAK";
};