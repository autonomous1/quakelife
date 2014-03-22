// Half-life Weapons and ammo stuff. I accidentally got Half-Life 2's weapons list so some of these
// are not even in HL1 lol. There's more HL weapons/items stuff in replace.qc from basemod too.
void () item_ammo_pistol =
{
	item_shells();
};

void () weapon_mp5 =
{
	weapon_supernailgun();
};

void () ammo_mp5clip =
{
	item_spikes();
};

void () ammo_mp5grenades =
{
	if (random() < .8)
		item_rockets();
	else
		weapon_grenadelauncher();
};

void () ammo_glockclip =
{
	item_shells();
};

void () item_ammo_pistol_large =
{
	self.spawnflags = WEAPON_BIG2;
	item_shells();
};

void () item_ammo_smg1 =
{
	item_spikes();
};

void () item_ammo_smg1_large =
{
	self.spawnflags = WEAPON_BIG2;
	item_spikes();
};

void () item_ammo_ar2 =
{
	if (random() < .7)
		item_rockets();
	else
		item_cells();
};

void () item_ammo_ar2_large =
{
	self.spawnflags = WEAPON_BIG2;
	if (random() < .7)
		item_rockets();
	else
		item_cells();
};

void () item_box_buckshot =
{
	self.spawnflags = WEAPON_BIG2;
	item_shells();
};

void () item_smg1_grenade =
{
	ammo_mp5grenades();
};

void () item_box_sniper_rounds =
{
	item_ammo_ar2_large();
};

// for breakables
void () SetSpawnObject =
{
	if (self.spawnobject == 1) item_armor1();
	else if (self.spawnobject == 2) item_healthkit();
	else if (self.spawnobject == 3) item_ammo_pistol();
	else if (self.spawnobject == 4) item_ammo_pistol_large();
	else if (self.spawnobject == 5)   	item_ammo_smg1();
	else if (self.spawnobject == 6)   	item_ammo_smg1_large();
	else if (self.spawnobject == 7)   	item_smg1_grenade();
	else if (self.spawnobject == 8)   	weapon_supershotgun();
	else if (self.spawnobject == 9)   	item_box_buckshot();
	else if (self.spawnobject == 10)   	weapon_supernailgun();
	else if (self.spawnobject == 11)   	item_box_sniper_rounds();
	else if (self.spawnobject == 12)   	item_ammo_ar2_large();
	else if (self.spawnobject == 13)   	item_ammo_ar2_large();
	else if (self.spawnobject == 14)   	weapon_rocketlauncher();
	else if (self.spawnobject == 15)   	item_rockets();
	else if (self.spawnobject == 16)   	item_cells();
	else if (self.spawnobject == 17)   	weapon_grenadelauncher();
	else if (self.spawnobject == 18)   	weapon_nailgun();
	else if (self.spawnobject == 19)   	weapon_supernailgun();
	else if (self.spawnobject == 20)   	item_ammo_ar2_large();
	else if (self.spawnobject == 21)   	weapon_lightning();
};