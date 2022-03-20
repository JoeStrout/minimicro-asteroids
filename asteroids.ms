import "listUtil"
import "mathUtil"

clear
sheet2x = file.loadImage("pics/Asteroids-2X.png")
images = {}
images.ship = sheet2x.getImage(64*3, 0, 96, 64)
images.shipThrusting = sheet2x.getImage(64*3+96, 0, 96, 64)
images.bullet = sheet2x.getImage(sheet2x.width-64, 0, 32, 32)
images.debris = images.bullet
images.ufoBullet = sheet2x.getImage(sheet2x.width-32, 0, 32, 32)
images.ufo = sheet2x.getImage(sheet2x.width-96, 16*5, 96, 80)
images.rocks = list.init2d(3,3) // index by: [type][size], each 0-2
for type in range(0,2)
	images.rocks[type][0] = sheet2x.getImage(160*type, 96+64, 160,160)
	images.rocks[type][1] = sheet2x.getImage(96*type, 64, 96,96)
	images.rocks[type][2] = sheet2x.getImage(64*type, 0, 64,64)
end for

// Prepare sounds
bipBoop = [new Sound, new Sound]
bipBoop[0].init 0.1, noteFreq(42), [0.3,0]
bipBoop[1].init 0.1, noteFreq(44), [0.3,0]

GameSprite = new Sprite
GameSprite.scale = 0.5
GameSprite.v = null  // x and y
GameSprite.update = function(dt)
	self.x = self.x + self.v.x * dt
	if self.x > 1040 then
		self.x = -80
	else if self.x < -80 then
		self.x = 1040
	end if
	self.y = self.y + self.v.y * dt
	if self.y > 720 then
		self.y = -80
	else if self.y < -80 then
		self.y = 720
	end if
end function
GameSprite.init = function
	self.v = {"x":0, "y":0}
	display(4).sprites.push self
end function
GameSprite.destroy = function
	display(4).sprites.removeVal self
end function

zeroZero = {"x":0, "y":0}

ship = new GameSprite
ship.image = images.ship
ship.acceleration = 2000  // pixels/sec/sec
ship.deceleration = 300   // pixels/sec/sec
ship.turnRate = 720  // degrees/sec
ship.fireWasPressed = false
ship.localBounds = new Bounds
ship.localBounds.width = 64
ship.localBounds.height = 32
ship.tint = color.lime
ship.reset = function
	self.x = 480
	self.y = 320
	self.rotation = 0
end function
ship.update = function(dt)
	// turn
	turn = key.axis("Horizontal")
	self.rotation = self.rotation - turn * self.turnRate * dt
	
	// thrust
	thrust = key.axis("Vertical")
	if thrust < 0 then thrust = 0
	radians = self.rotation * pi/180
	self.v.x = self.v.x + cos(radians) * thrust * self.acceleration * dt
	self.v.y = self.v.y + sin(radians) * thrust * self.acceleration * dt
	
	// fire bullets
	fireIsPressed = key.pressed("space")
	if fireIsPressed and not self.fireWasPressed then
		b = new Bullet
		b.init
		b.x = self.x + cos(radians)*16
		b.y = self.y + sin(radians)*16
		b.v.x = self.v.x + cos(radians)*500
		b.v.y = self.v.y + sin(radians)*500
	end if
	self.fireWasPressed = fireIsPressed
	
	// apply friction
	mathUtil.moveTowardsXY self.v, zeroZero, self.deceleration * dt
	
	super.update dt
end function
ship.destroy = function
	super.destroy
	makeDebris self
end function
ship.init

TimedSprite = new GameSprite
TimedSprite.despawnTime = 0
TimedSprite.init = function(duration = 0.5)
	super.init
	self.despawnTime = time + duration
end function
TimedSprite.update = function(dt)
	if time > self.despawnTime then
		self.destroy
	else
		super.update dt
	end if
end function

Bullet = new TimedSprite
Bullet.image = images.bullet
Bullet.instances = []
Bullet.init = function
	super.init 0.6
	Bullet.instances.push self
end function
Bullet.destroy = function
	super.destroy
	Bullet.instances.removeVal self
end function

Rock = new GameSprite
Rock.size = 0
Rock.init = function(size=0)
	super.init
	self.size = size
	self.image = images.rocks[rnd*3][self.size]
	self.localBounds = new Bounds
	self.localBounds.width = self.image.width * 0.75
	self.localBounds.height = self.image.height * 0.75	
	self.spin = 360 * (rnd - 0.5)
end function
Rock.destroy = function
	super.destroy
	makeDebris self
	if self.size < 2 then
		// break into two rocks of the next size down
		Rock.make self.size+1, self
		Rock.make self.size+1, self
	end if
end function
Rock.update = function(dt)
	self.rotation = self.rotation + self.spin * dt
	if self.overlaps(ship) then
		ship.destroy
		self.destroy
	else
		for b in Bullet.instances
			if self.contains(b) then self.destroy	
		end for	
	end if
	super.update dt
end function
Rock.make = function(size=0, position=null)
	rock = new Rock
	rock.init size
	if position then
		rock.x = position.x
		rock.y = position.y
	else
		rock.x = 960 * rnd
		rock.y = 640 * rnd
	end if
	rock.v.x = (rnd-0.5) * 300
	rock.v.y = (rnd-0.5) * 300
end function

makeDebris = function(pos)
	for i in range(10)
		d = new TimedSprite
		d.init
		d.image = images.debris
		d.x = pos.x; d.y = pos.y
		d.v.x = (rnd-0.5) * 300
		d.v.y = (rnd-0.5) * 300		
	end for
end function

heartbeat = {}
heartbeat.nextPlayTime = 0
heartbeat.which = 0
heartbeat.interval = 0.75
heartbeat.update = function(dt)
	if time > self.nextPlayTime then
		bipBoop[self.which].play
		self.nextPlayTime = time + self.interval
		self.which = not self.which
	end if
end function

// Board setup
ship.reset
for i in range(0,7)
	Rock.make
end for

// Main loop
lastTime = time
while true
	dt = time - lastTime
	lastTime = time
	for sp in display(4).sprites
		sp.update dt
	end for
	heartbeat.update dt
end while