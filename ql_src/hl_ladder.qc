// func_ladder
/*
	Written by Frank Condello <pox@planetquake.com>
	
	Misc functions/entities....
	
	func_ladder
	func_explobsp
	func_breakaway
	func_nodraw
	func_bspframe
	func_model
*/

//============================================================================

float LADDEROFS = 0.36;// touchy...
#define LADDER_MOVESPEED	400

// This is tricky cause we can't just check key presses...
void() ladder_touch =
{
	local vector vel, pvec;
	float fvel, spd;
	
	if (other.classname != "player") return;
	
	// FIXME! - time out for teleporters?
	
	// Don't stick underwater, or in the middle of a waterjump
	if (other.waterlevel > 1 || other.fwatershifttime > time) return;
	if (other.flags & FL_WATERJUMP) return;
	
	
	makevectors (other.v_angle);
	pvec = v_forward;
	pvec = (pvec * 250);
	if (other.button2)		// jump off the ladder
		other.velocity = pvec;
	
	// Don't re-grab right away if jumping
	if (other.ladderjump > time) return;
	
	// Check if the player can grab the ladder
	makevectors (other.angles);
	if (v_forward*self.movedir<-0.5)// a little more than 180¼ of freedom
		return;// not facing the right way
	
	// Avoid problems if the player is on the top edge (act like an 8 unit step)
	if (other.origin_z + other.mins_z + 8 >= self.absmax_z) {
		if ((!other.flags & FL_ONGROUND))
			other.flags = other.flags + FL_ONGROUND;
		return;
	}
	
	// Null out gravity in PreThink
	other.laddertime = other.zerogtime = time + 0.1;

/*	FIXME! - Physics on a moving ladder don't quite work
	// Factor in the parent train's movement
	if (self.owner) {
		
		// Stop all vertical movement
		other.velocity_z = self.owner.velocity_z;
		
		// Check if the player is moving sideways (don't go up/down)
		if (v_right*(other.velocity - self.owner.velocity) > 25) {
			other.velocity = self.owner.velocity;
			other.origin = other.origin + v_right*0.5;
			return;
		}
		else if (v_right*(other.velocity - self.owner.velocity) < -25) {
			other.velocity = self.owner.velocity;
			other.origin = other.origin - v_right*0.5;
			return;
		}
		
		// Get the player's forward speed	
		fvel = v_forward*(other.velocity - self.owner.velocity);
	
	} else {// Stationary		
*/	
		// Stop all vertical movement
		other.velocity_z = 0;
		
		// Check if the player is moving sideways (don't go up/down)
		/*if (fabs(v_right*other.velocity) > 25) {
			other.velocity = '0 0 0';
			return;
		}*/
		if (v_right*other.velocity > 25) {
			other.velocity = '0 0 0';
			other.origin = other.origin + v_right*0.5;// boost strafes
			return;
		}
		else if (v_right*other.velocity < -25) {
			other.velocity = '0 0 0';
			other.origin = other.origin - v_right*0.5;// boost strafes
			return;
		}
		
		// Get the player's forward speed	
		fvel = v_forward*other.velocity;
//	}
	
	vel = '0 0 0';// Our new velocity
	
	// Up (facing up/forward)
	if (other.v_angle_x <= 15 && fvel>0 ) {
		other.origin = other.origin - self.movedir*LADDEROFS;// Pull back to keep from hitting the backing wall
		vel_z = fabs(other.v_angle_x)*6;// go faster when facing forward	
		if (vel_z < 90) vel_z = 90;// minimum speed
	}
	// Up (facing down)
 	else if ( other.v_angle_x >= 15 && fvel<0 ) {
		other.origin = other.origin + self.movedir*LADDEROFS;// Pull in to keep from falling off
		vel_z = other.v_angle_x*4;
	}
	// Down (facing up/forward)
	else if (other.v_angle_x <= 15 && fvel<0 ) {	
		other.origin = other.origin + self.movedir*LADDEROFS;// Pull in to keep from falling off
		vel_z = fabs(other.v_angle_x)*-5;// go faster when facing forward	
		if (vel_z > -80) vel_z = -80;// minimum speed
	}
	// Down (facing down)
	else if ( other.v_angle_x >= 15 && fvel>0 ) {		
		other.origin = other.origin - self.movedir*LADDEROFS;// Pull back to keep from hitting the backing wall
		vel_z = other.v_angle_x*-4;
	}
	
	// Cap vertical moves to the server limits
	//spd = cvar("cl_upspeed");
	spd = LADDER_MOVESPEED;
	if (vel_z > spd) vel_z = spd;
	else if (vel_z < -1*spd) vel_z = -1*spd;
	
	// Add the parent's velocity - FIXME! - Physics on a moving ladder don't quite work
	//if (self.owner) vel = vel + self.owner.velocity;
	
	// Set the player's new veloctity
	other.velocity = vel;
};

/*QUAKED func_ladder (0 .5 .8) ?
Creates an invisible trigger area that the player can "climb" vertically.

Dependant on additions in client.qc, and player.qc

The movement was initially intended to mimic ladders in RTCW, but there
are some differences due to QuakeC limitations, and personal preference
(jumping behaviour and speed can easily be changed).

"angle" The direction the player must be facing in order to climb
"targetname" use as a killtarget to delete the ladder
DISABLED: "target" Attach the ladder to a func_train_ext

------------------------------------------------------------------------------------
BUGS:
- up/down keys don't climb (only way is to use MOVETYPE_FLY, which means current touch code is useless)
- DISABLED: physics break when the player is trying to move in the same direction as a ladder's parent train

------------------------------------------------------------------------------------
USEAGE NOTES:

These work best when they are at least 8 units thick.

Make sure the angle is set correctly. All movement revolves around the ladder's
facing angle. (Remember: It's the angle the PLAYER must be facing to climb)

The top of the func_ladder brush should be flush with the top of the ledge (if the
ladder leads to a ledge). Ladders behave as if there's an 8 unit "step" at the top.

It's a good idea to back these up with a solid brush or a clipping brush.
Especially if using real geometry for the rungs. (i.e. to fill the gaps between the rungs)

If you need a "two-way" ladder (like a ladder hanging from a fire-escape) use a clip
brush in the middle, and two func_ladders on either end with opposite facing angles.

Avoid situations where more than one func_ladder can be touched at the same time.

*/
void() func_ladder =
{
	InitTrigger();
	self.touch = ladder_touch;

/*	FIXME! - Physics on a moving ladder don't quite work
	// Attach the ladder to it's parent
	if (self.target) {
		self.think = train_ext_linkchild;
		self.nextthink = time + 0.2;
	}
*/
};


/*
// GOLD: old ladder_touch:
void () ladder_touch_old =
{
	local vector pvec;

	if (other.classname != "player")
		return;
	
	makevectors (other.v_angle);
	pvec = v_forward;
	pvec = (pvec * 250);
	if (other.button2)		// jump off the ladder
		other.velocity = pvec;
	else
		other.velocity_z = pvec_z;
};
*/