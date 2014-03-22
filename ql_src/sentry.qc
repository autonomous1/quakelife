/**
 * sentry.qc
 **/

$frame stand1
$frame shot1 shot2 shot3 shot4 shot5 shot6 shot7 shot8
$frame spin1 spin2 spin3 spin4 spin5 spin6 spin7 spin8

.float aflag;

void() OgreGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 40, 40, world, MOD_HLIFE);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() stry_spike =
{
    local vector    dir;

    sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    dir = aim (self, 1000);
    launch_spike (self.origin + '0 0 16', dir);
    newmis.touch = superspike_touch;
    setmodel (newmis, "progs/s_spike.mdl");
    setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
};

void () stry_stand =
{
    local float r;

    ai_stand();
    if (self.enemy != world)
    {
        ai_face();
        r = range (self.enemy);
        if (r == RANGE_FAR)
        {
            self.enemy = world;
        }

        if (!visible (self.enemy))
        {
            self.enemy = world;
        }
    }

    if (self.enemy == world)
    {
        if (self.aflag > 0)
        {
            sound (self, CHAN_VOICE, "doors/hydro2.wav", 1, ATTN_NORM);
            // bprint ("sentry: deactivating...\n");
            self.aflag = 0;
            self.frame = $stand1;
        }

        // seeks for enemies
        self.angles_y = self.angles_y + 3;
        if (self.angles_y > 359)
        {
            self.angles_y = self.angles_y - 359;
        }

        if (self.wait < time)
        {
            sound (self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
            self.wait = time + 2;
        }
    }
    else
    {
        if (self.aflag == 0)
        {
            // bprint ("sentry: enemy found!\n");
            sound (self, CHAN_VOICE, "doors/hydro1.wav", 1, ATTN_NORM);
            self.aflag = 1;
            self.cnt = 0;
        }
        else
        {
            if ((r == RANGE_NEAR) || (r == RANGE_MELEE))
            {
                // bprint ("sentry: enemy in range!\n");
                if (infront (self.enemy))
                {
                    self.aflag = 2;
                }
            }
            else
            {
                self.aflag = 1;
            }
        }
    }

    if (self.aflag == 1)
    {
        self.frame = $spin1 + self.cnt;
        self.cnt = self.cnt + 1;
        if (self.cnt > 7)
        {
            self.cnt = 0;
        }
    }
    else if (self.aflag == 2)
    {
        self.frame = $shot1 + self.cnt;
        stry_spike ();
        self.effects = self.effects | EF_MUZZLEFLASH;
        self.cnt = self.cnt + 1;
        if (self.cnt > 7)
        {
            self.cnt = 0;
        }
    }

    self.think = stry_stand;
    self.nextthink = time + 0.1;
};


void () stry_die =
{
    local float r;

    OgreGrenadeExplode();
    r = random();
    if (r > 0.66)
    {
        ThrowHead ("progs/strygib1.mdl", -120);
        ThrowGib ("progs/strygib2.mdl", -120);
        ThrowGib ("progs/strygib3.mdl", -120);
    }
    else if (r > 0.33)
    {
        ThrowHead ("progs/strygib2.mdl", -120);
        ThrowGib ("progs/strygib1.mdl", -120);
        ThrowGib ("progs/strygib3.mdl", -120);
    }
    else
    {
        ThrowHead ("progs/strygib3.mdl", -120);
        ThrowGib ("progs/strygib1.mdl", -120);
        ThrowGib ("progs/strygib2.mdl", -120);
    }
};

void () monster_sentry =
{
    precache_model ("progs/sentry.mdl");
    precache_model ("progs/strygib1.mdl");
    precache_model ("progs/strygib2.mdl");
    precache_model ("progs/strygib3.mdl");

    precache_sound ("misc/talk.wav");
    precache_sound ("doors/hydro1.wav");
    precache_sound ("doors/hydro2.wav");



    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;

    setmodel (self, "progs/sentry.mdl");

    setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.health = 200;

    self.th_stand = stry_stand;
    self.th_walk = stry_stand;
    self.th_run = stry_stand;
    self.th_die = stry_die;
    self.th_pain = SUB_Null;
    self.aflag = 0;

	if (#HL_MAP)
		self.origin_z += 30;
	
    walkmonster_start();
};