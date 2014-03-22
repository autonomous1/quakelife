// conveyor belt!
void () conveyor_think =
{
/*
	local entity oself;
	oself = self;
	self = self.owner;

	if (self.frame == 1) {
		self.frame = 0;
		self.origin_z += .5;
	}
	else {
		self.origin_z -= .5;
		self.frame = 1;
	}
		
	self = oself;
	*/
	self.nextthink = time + .05;
};
void () conveyor_touch =
{
	local vector pvec;

	if (other.classname != "player")
		return;
	makevectors (self.v_angle);
	if (self.has_tesla == 180)
		pvec = v_forward * -1;
	else if (self.has_tesla == 270)
		pvec = v_right;
	else if (self.has_tesla == 90)
		pvec = v_right * -1;
	else
		pvec = v_forward;
	//pvec_y = self.has_tesla;
	//pvec_y += self.has_tesla;
	pvec = (pvec * (self.speed/13));
	
	other.velocity += pvec;
};

void () conveyor_use =
{
	if (self.has_tesla == 180)
		self.has_tesla = 0;
	else if (self.has_tesla == 270)
		self.has_tesla = 90;
	else if (self.has_tesla == 90)
		self.has_tesla = 270;
	else
		self.has_tesla = 180;
};

void () func_conveyor =
{
	self.solid = 4.000;
	self.movetype = 7.000;
	setorigin (self, ((self.mins+self.maxs)*.5));  
	setmodel (self, self.model);
	self.has_tesla = self.angles_y;
	self.angles = '0 0 0';
	
	newmis = spawn();
	newmis.owner = self;
	newmis.think = conveyor_think;
	newmis.nextthink = time + .1;
	
	self.touch = conveyor_touch;
	self.use = conveyor_use;

	if (!self.speed)
		self.speed = 140;
};
