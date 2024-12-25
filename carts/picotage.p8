pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--picotage!
--by jim bourke

--[[
copyright 2021 jim bourke, knife edge software
i was inspired by sabotage (1981) for the apple 2

haphazardly hacked together in the spirit of pico 8!
]]--

function _init()

	cartdata("jimbourke_picotage_1")

-- reset high score
--score=0
--savehighscore()

	highscore=gethighscore()
	
	cheat_code={⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️}
	killme_code={⬇️,⬇️,⬆️,⬆️,➡️,⬅️,➡️,⬅️}
	
	chsys={}
	add_chsys(cheat_code,function() cheat() end)
	add_chsys(killme_code,function() for i=1,100 do base.damage+=1 end end)

	initvars()
	
	nintroparticles=33
	while (nintroparticles>0) do
		addparticle(64+15-rnd(30),30+rnd(12),-1.5+rnd(3),-.6+rnd(1.2),smoke)
		addparticle(64+15-rnd(30),30+rnd(12),-2+rnd(4),-1+rnd(2),chaff)
		addparticle(64+15-rnd(30),30+rnd(12),-2+rnd(4),-1+rnd(2),bigfire)
		nintroparticles-=1
	end
	
	sfx(16)
end

function cheat()
	addnuke() 
	addnuke() 
	addnuke() 
	addnuke() 
	addnuke() 
	base.damage=0 
	stage+=15
end

function initvars()
	gstatus={
		introducing=1,
		loading=2,
		playing=3,
		pausing=4
	}
	initbullets()
	initbase()
	initparticles()
	inithelis()
	initsoldiers()
	score=0
	gamestatus=gstatus.introducing
	stage=1
	t=0
	tlastheli=0
	leveltime=1200
	nukes=0
	haventplayedwhoop=true
	firstblood=false
end

function _update60()
	if (gamestatus==gstatus.introducing) then
		introupdate()
	elseif (gamestatus==gstatus.loading) then
		loadupdate()
	elseif (gamestatus==gstatus.playing) then
		gameupdate()
	elseif (gamestatus==gstatus.pausing) then
		pauseupdate()
	end
end

function gameupdate()
	for c in all(chsys) do
		c:upd()
	end
	
	helichance=1
	echance=0
	
	helichance=(stage/15)/30
	echance=max(0,(stage-7))/60
	
	if (stage==5) and
		(t==240) then
		helichance=1
		echance=1
	end
	
	e=false
	if (stage>1) then
		if (rnd(1)<echance) e=true
	end

	if (
		(rnd(1) < helichance) or
		(tlastheli>300)
		) then
		addheli(e)
		tlastheli=0
	else
		tlastheli+=1
	end

	updatehelis()
	updatebase()	
	updatebullets()
	updatesoldiers()
	updateparticles()

	checkdamage()

	updatestage()
end

function checkdamage()
	if (base.damage>=base.hitpoints) then
		sfx(8)
		gamestatus=gstatus.pausing
		helpmsgs=
			{
				"❎ activates powerups",
				"shoot the chutes!",
				"the red troops are elite",
				"elite troops have shields",
			 "⬆️ moves cannon to center",
			 "⬇️ nudges cannon lower",
			 "elite units block bullets",
			 "powerups heal your base",
				"aim up to bounce bullets",
				"powerups come with time",
				"helis get you more points",
				"konami code!!!"
			}
		helpmsg="hint: "..rnd(helpmsgs)
		if (score > highscore) then
			highscore=score
			savehighscore()
			helpmsg="new high score!!!!!"
		end

	end
end

function updatestage()
	if(firstblood)t+=1
	if (t > leveltime)	then
		t=0
		stage+=1
		if (stage%5 == 0) then
			addnuke()
		end
	end
end

function addnuke()
	nukes+=1
	if (nukes > 3) then
		nukes=3
	end
	sfx(16)
end

function introupdate()
	updateparticles()
	if (time() > 5) and 
		(#helis==0) then
		addheli(false)
	end
	updatehelis()
	initsoldiers()
	if (btnp(5)) then
		sfx(19)
		gamestatus=gstatus.loading
		initparticles()
		inithelis()
		initsoldiers()
		nintroparticles=33
		while (nintroparticles>0) do
			addparticle(64+20-rnd(40),64+20-rnd(40),-1.5+rnd(3),-.6+rnd(1.2),smoke)
			addparticle(64+20-rnd(40),64+20-rnd(40),-2+rnd(4),-1+rnd(2),chaff)
			addparticle(64+20-rnd(40),64+20-rnd(40),-2+rnd(4),-1+rnd(2),bigfire)
			nintroparticles-=1
		end
	end
end

function loadupdate()
 updatebase()
 updateparticles()
	if (btnp(5)) then
		gamestatus=gstatus.playing
		initparticles()
		sfx(19)
	end
end

function pauseupdate()
	if (btnp(5)) then
		initvars()
		gamestatus=gstatus.playing
	end
	updatebase()
	updatehelis()
	updatebullets()
	updatesoldiers()
	updateparticles()
end

function _draw()
	cls()
	pal()
	if (gamestatus==gstatus.introducing) then
		introdraw()
	elseif (gamestatus==gstatus.loading) then
		loaddraw()
	elseif (gamestatus==gstatus.playing) then
		gamedraw()
	elseif (gamestatus==gstatus.pausing) then
		pausedraw()
	end
end

function introdraw()
	drawbackground()
	drawparticles()
	drawintro()
end

function loaddraw()
	drawbase()
	drawbackground()
	drawparticles()
	drawinstructions()
	drawhighscore()
end

function pausedraw()
	drawbase()
	drawhelis()
	drawsoldiers()
	drawparticles()
	drawbullets()
	drawhighscore()
	drawyourscore()
	drawbackground()
	drawinstructions(true)
	drawtitle()
end

function gamedraw()
	drawhelis()
	drawsoldiers()
	drawbullets()
	drawbase()
	drawparticles()
	drawhud()
	drawbackground()
end

function drawhighscore()
	highscore=highscore or 0
	if(highscore == 0) return
	highscoretext="high score: "..u32_tostr(highscore)
	print (highscoretext,64-(#highscoretext*2),3,7)
end

function drawyourscore()
	yourscoretext="your score: "..u32_tostr(score)
	print (yourscoretext,64-(#yourscoretext*2),11,7)
end

function drawhud()
	scoretext=u32_tostr(score)
	print (scoretext,125-(4*#scoretext),3,7)
	
	leveltext="level: "..stage
	leveltimeremaining=leveltime-(t%leveltime)
	if (leveltimeremaining<120) then
		levelcolor=8
	else
		levelcolor=7
	end
	print (leveltext,64-(#leveltext*2),3,levelcolor)

	hmsg='♥ '
	if(base.damage>0) hmsg=hmsg..' '
	hmsg=hmsg..(100-base.damage)
	hcolor=7
	if(base.damage > 50) hcolor=10
	if(base.damage > 75) hcolor=9
	if(base.damage > 90) hcolor=8
	print(hmsg,3,3,hcolor)	
--	print("fps: "..stat(7),3,11,hcolor)	
--	print("bulletlist: "..#bulletlist,3,19,hcolor)	
--	print("helis: "..#helis,3,27,hcolor)	
--	print("soldiers: "..#soldiers,3,35,hcolor)	
--	print("particles: "..#particles,3,43,hcolor)	
--	print("#loops: "..#particles+(#bulletlist*#soldiers)+(#bulletlist*#helis)+#bulletlist,3,51,hcolor)	
	nx=nukes
	if(base.powerup>0) nx+=1
	hpos=0
	if (nx >=1) then
		drawx(1,9)
		hpos=1
	end
	if (nx >=2) then
		drawx(2,9)
		hpos=2
	end
	if (nx >= 3) then
		drawx(3,9)
		hpos=3
	end
	if (base.powerup>0) and
	 (((flr(base.powerup/30))%2) == 0) then
		drawx(hpos,5)
	end
end

function drawx(pos,c)
	x=125-(8*pos)
	y=10
	print ('❎',x,y,c)
end

function dropshadowtext(txt,offset,c1,c2)
	print(txt,hcenter(txt)+1,vcenter(txt)+offset+1,c2)
	print(txt,hcenter(txt),vcenter(txt)+offset,c1)
end


function boxtext(txt,offset,c1,c2)
	textwidth=#txt*4
	textheight=5
	x1=64-(textwidth/2)-2
	y1=vcenter(txt)+offset-2
	x2=64+(textwidth/2)
	y2=vcenter(txt)+offset+6
	rectfill(x1,y1,x2,y2,c2)
	print(txt,hcenter(txt),vcenter(txt)+offset,c1)
end

function drawintro()

	drawtitle()	

	if (time() > 2) then
		drawbase()
	elseif (time() > 1) then
		if (rnd() < time()/2) then
			drawbase()
			if (haventplayedwhoop) then
				sfx(20)
				haventplayedloop=false
			end
			addparticle(64-10+rnd(20),115+rnd(12),-1+(rnd(2)),-.5-rnd(1),chaff)
		end
	end
	if (time() > 4) then
		drawhelis()
	end
	if (time() > 6) then
		drawsoldiers()
	end
	
	ty=-12
	if(time()>1) dropshadowtext("by jim bourke",ty,7,5)
	ty+=16
	if(time()>3) dropshadowtext("  a pico-8 version  ",ty,12,1)
	ty+=8
	if(time()>3) dropshadowtext(" of sabotage (1981) ",ty,12,1)

	ty+=16
	if(time()>5) dropshadowtext("press x to continue",ty,12,1)
end

function drawtitle()
	sp=130
	w=49
	w2=w
	h=20
	sx, sy = (sp % 16) * 8, (sp \ 16) * 8
	sspr(sx,sy,w,h,63-(w/2),30,w,h)
end

function drawinstructions(v)
	drawtitle()
	
	stagedisplay=v or false
	
	ty=-12
	if stagedisplay then
		if (stage<5) then
			exclaim=""
		elseif (stage<10) then
			exclaim="nice. "
		elseif (stage<15) then
			exclaim="hey! "
		elseif (stage<20) then
			exclaim="cool! "
		elseif (stage<25) then
			exclaim="wow! "
		elseif (stage<30) then
			exclaim="what?! "
		else
			exclaim="!!! "
		end
		dropshadowtext(exclaim.."made it to level "..stage.."!",ty,12,1)
		ty+=8
		dropshadowtext(helpmsg,ty,12,1)
	else
		dropshadowtext("survive as long as you can",ty,12,1)
	end
	ty+=12
	txt="aim with arrow keys"
	dropshadowtext("aim with arrow keys",ty,10,4)

	ty+=8
	dropshadowtext("press z to fire!",ty,10,4)
	ty+=8
	dropshadowtext("press x to activate powerups!",ty,10,4)

	ty+=16
	if (stagedisplay) then
		boxtext("press x to try again",ty,12,1)
	else
		boxtext("press x to begin",ty,12,1)
	end

end

function drawbackground()
--	rect(0,0,127,127,12)
	line (0,127,127,127,3)
end
-->8
-- utilities

o={
			x=0,
			y=0,
			hitbox={x=0,y=0,w=0,h=0}
			}
			
function r(value,pct)
	return value-pct + (rnd(pct*2))
end

function move(t)
	t.x+=t.dx
	t.y+=t.dy
end

function shallowcopy(org)
	local t={}
	for key, value in pairs(org) do
	  t[key] = value
	end
 return (t)
end

function collidepixel(obj,pt)
	--rect(obj.x+obj.hitbox.x,obj.y+obj.hitbox.y,obj.x+obj.hitbox.x+obj.hitbox.w,obj.y+obj.hitbox.y+obj.hitbox.h)
	o.x=pt.x
	o.y=pt.y
	return collide(obj,o)
end

function collide(obj, other)
 if
 	other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x and 
  other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y and
  other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w and
  other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h 
 then
  return true
 end
end

function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end

function vcenter(s)
  -- screen center minus the
  -- string height in pixels,
  -- cut in half
  return 61
end

function u32_tostr(v)
    local s=""
    repeat
        local t=v>>>1
        s=(t%0x0.0005<<17)+(v<<16&1)..s
        v=t/5
    until v==0
    return s
end

function addscore(num)
	firstblood=true
	if (stage > 5) then
		num=num*3
	elseif (stage>10) then
		num=num*5
	elseif (stage>15) then
		num=num*10
	elseif (stage>20) then
		num=num*15
	elseif (stage>30) then
		num=num*20
	end
	if (gamestatus==gstatus.playing) then
		score += (num*10) >> 16
	end
end

function savehighscore()
	sval=tostr(score,true)
	for i=1,11 do
		dset(i,ord(sub(sval,i,i)))
	end
end

function gethighscore()
	val=""
	for i=1,11 do
	 val=val..chr(dget(i))
	end
	return (tonum(val))	
end

function add_chsys(table,func)
--function required!!!
--arguments are table and what the cheat will do once it's done
add(chsys,{
cnt=1,
chtb=table,
func=func,
upd=function(self)

if self.cnt<=#self.chtb then
	for i=0,5 do
			if btnp(i) then
				if i==self.chtb[self.cnt] then
				self.cnt+=1
				else
				self.cnt=1
				end
			end
	end
else
	self.func()
	self.cnt=1
end

end,

})
end


function approx_dist(o1,o2)
	local dx=o1.x-o2.x
	local dy=o1.y-o2.y
 local maskx,masky=dx>>31,dy>>31
 local a0,b0=(dx+maskx)^^maskx,(dy+masky)^^masky
 if a0>b0 then
  return a0*0.9609+b0*0.3984
 end
 return b0*0.9609+a0*0.3984
end
-->8
--base

function initbase()
	base={
		x=56,
		y=119,
		hitbox={x=0,y=0,w=16,h=8},
		damage=0,
		hitpoints=100,
		powerup=0
		}
		
	turret={
		a=0,
		lasta=0,
		x=56,
		y=111,
		delta=2,
		maxa=100,
		kickt=0,
		hitbox={x=0,y=0,w=0,h=0}	
	}
	
	gun={
		basex=63,
		basey=114,
		temp=0
		}
		
	flipflop=false
	end

function checkbaseandbullet(b)
	if (b.y>100) then
		if (collidepixel(base,b)) then
			if (b.hitbasealready) then
			else
				b.dx+=-.2+rnd(.4)
				b.dx=sgn(b.dx) * max(.5,(abs(b.dx*5)))
				b.dy=-b.dy*.15
				b.hitbasealready=true
				sfx(10)
			end
		end
	end
end

function checkbaseandbullets()
	foreach(bulletlist,checkbaseandbullet)
end

function damagebase(hp)
	base.damage+=hp
end

function updatebase()
	checkbaseandbullets()
	if (flipflop) then
		flipflop=false
	else
		flipflop=true
	end
	if btnp(5) then
		if (nukes>0 and base.powerup<=0) then
			nukes-=1
			sfx(18)
			sfx(8)
			base.powerup=600
			if(stage > 25) base.powerup=900
			if (base.damage<50) then
				base.damage=0
			elseif (base.damage<75) then
				base.damage=25
			else
				base.damage=50
			end
			for i=1,15 do
				addparticle(60+rnd(8),120+rnd(5),-3+rnd(6),-1+rnd(1),fire)
				addparticle(60+rnd(8),120+rnd(5),-3+rnd(6),-1+rnd(1),smoke)
				addparticle(60+rnd(8),120+rnd(5),-3+rnd(6),-1+rnd(1),blood)
			end
			for i=1,#soldiers do
				sol=soldiers[i]
				sol.h-=rnd(5)
				vdx=(-(64-sol.x)/64)
				vdy=(-(128-sol.x)/128)
				sol.dx+=vdx
				sol.dy+=vdy
				if (sol.state==sstate.flying) then
					addparticle(sol.x,sol.y-5,vdx,vdy,smoke)
				end
				addparticle(sol.x,sol.y,-.5+rnd(1),-.5+rnd(1),blood)
				sol.state=sstate.splatting
--				if (sol.x > 44) and (sol.x < 85) then
 --				sol.h-=10	
		--			sol.state=sstate.splatting
			--		sol.dy-=1
			--	elseif (sol.y > 100) then
 		--		sol.h-=rnd(10)
 		--		sol.dy-=.5
			--	end
			end
			for i=1,#helis do
				vdx=(-(64-heli.x)/64)
				vdy=(-(128-heli.x)/128)
				heli.dx+=vdx/10
				heli.dy+=vdy/10
				heli=helis[i]
				heli.h-=rnd(20)
				addparticle(heli.x,heli.y,-.5+rnd(1),-.5+rnd(1),fire)
				addparticle(heli.x,heli.y,-.5+rnd(1),-.5+rnd(1),smoke)
			end
		else
		 sfx(19)
		end
	end

	if (btn(3)) then
		ta=1
		if (turret.a==0) then
			ta=0
		elseif (turret.a<0) then
			ta=-1
		end
		turret.a+=ta
	end
	
	if (
		(btn(2)) and 
		(not btn(0)) and 
		(not btn(1)) and
		(turret.a ~=0)
		) then
		turret.a+=-sgn(turret.a)*turret.delta
	end
	if(btn(0)) turret.a-=turret.delta
	if(btn(1)) turret.a+=turret.delta
	bx=rnd({0,1})
	gun.color=6
	if
		(btn(4)) and 
		(
			(gun.temp<15) or 
			(
				(base.powerup>0) and 
				(flipflop)
			)
		)
		 then
		tempadd=5
		if (stage<=5) then
			tempadd=6
		elseif (stage >= 10) then
			tempadd=4
		elseif (stage >= 15) then
			tempadd=3
		end
		gun.temp=gun.temp+tempadd
	 basex=turret.x+7
 	basey=turret.y+3
		if (gamestatus==gstatus.playing) then
			sfx(9)
			huge=false
			a=turret.a
			if(base.powerup>0) huge=true
			dmg=1
			if(stage>=15) dmg=2
			if(stage>=20) dmg=3
			if(stage>=25) dmg=4
			if(stage>=30) dmg=5
			if(stage>=35) dmg=6
			bulletspeed=3
			if(huge) bulletspeed=3+rnd(3)
			addbullet(
				basex+bx,
				basey,
				-sin(a/360)*bulletspeed+(-.025+rnd(.05)),
				-cos(a/360)*bulletspeed+(-.025+rnd(.05)),
				huge,
				dmg)
				shelldir=rnd({-1,1})
				addparticle(gun.basex+(2*shelldir),gun.basey+2,.4*shelldir,-.4,shell)
			turret.kickt=5
			turret.lasta=turret.a
		end
 	tipx=basex-5*sin(turret.a/360)
 	tipy=basey-5*cos(turret.a/360)		
		addparticle(tipx,tipy,-sin((turret.a-30+rnd(60))/360),-cos((turret.a-30+rnd(60))/360),fire)
		addparticle(tipx,tipy,-sin((turret.a+(60+rnd(30)))/360)*(.5+rnd(.5)),-cos((turret.a+(60+rnd(30)))/360)*(.5+rnd(.5)),puff)
		addparticle(tipx,tipy,-sin((turret.a-(60+rnd(30)))/360)*(.5+rnd(.5)),-cos((turret.a-(60+rnd(30)))/360)*(.5+rnd(.5)),puff)
	else
		tempsub=.7
		if (stage >= 15) then
			tempsub=.8
		elseif (stage >= 20) then
			tempsub=.9
		elseif (stage >= 25) then
			tempsub=1
		elseif (stage >= 30) then
			tempsub=1.1
		end
		gun.temp=gun.temp-tempsub
		if(gun.temp < 0) gun.temp=0
	end

	if(turret.a>turret.maxa) turret.a=turret.maxa
 if(turret.a<-turret.maxa) turret.a=-turret.maxa

	turret.kickt-=1
	turret.kickt=max(turret.kickt,0)
	
	if (base.powerup == 1) then
		gun.temp=0
	end
	base.powerup-=1
	if(base.powerup<0) base.powerup=0
end

function drawbase()
	if (base.damage > (base.hitpoints*.8)) then
		local c=10
		if (base.damage > (base.hitpoints*.9)) then
			c=8
		end
		if (rnd(1) > .5) then
			pal(6,c)	
		end
	end
	spr(19,base.x,base.y)
	spr(20,base.x+8,base.y)
	spr(3,turret.x,turret.y)
	spr(4,turret.x+8,turret.y)
	pal()
	if (gamestatus~=gstatus.pausing) then
		drawgun(turret.a,gun.color)
	else 
		drawkaboom()
	end
end

function drawkaboom()
	offset=1.5
	addparticle(60+rnd(8),120,-1+rnd(2),-1-rnd(2),fire)
	addparticle(60+rnd(8),120,-.5+rnd(1),-rnd(1),fire)
	addparticle(60+rnd(8),120,-1+rnd(2),-1-rnd(2),bigfire)
	addparticle(60+rnd(8),120,-1+rnd(2),-rnd(2),bigfire)
	addparticle(60+rnd(8),120,-1+rnd(2),-rnd(1),smoke)
end

function drawgun()
	guncolor=6
--	gunlength=5-turret.kickt
--	if (turret.kickt > 0) then
--		gunlength-=kickt
--		guncolor=10
--	end
gunlength=5
	if (base.powerup >0) then
		guncolor=rnd({6,8,9,10})
		gunlength=6
	end
--if (turret.kickt>0) then 
--guncolor=9
--end
--	if(guncolor!=6) gunlength=3
	drawgunpiece(gun.basex,gun.basey,turret.a,gunlength,guncolor)
	drawgunpiece(gun.basex+1,gun.basey,turret.a,gunlength,guncolor)
end

function drawgunpiece(x,y,a,l,c)
	tipx=x-l*sin(a/360)
	tipy=y-l*cos(a/360)
	line (x,y,tipx,tipy,c)
end
-->8
--bullets
function initbullets()
	bulletlist={}
end

function addbullet(x,y,dx,dy,huge,damage)
--	if(#bulletlist > 30) return
	add(bulletlist,{x=x,y=y,dx=dx,dy=dy,t=0,hitbasealready=false,damage=damage,huge=huge})
end

function updatebullet(bullet)
	bullet.x+=bullet.dx
	bullet.y+=bullet.dy
	bullet.t+=1
	bullet.dy=bullet.dy+.04
	if (bullet.x < -4) or
		(bullet.x>132) or
		(bullet.y < -4) or
		(bullet.y>127) then
		if (bullet.y>127) then
			sfx(11,0,flr(rnd(32)),flr(rnd(4)+1))
			addparticle(bullet.x+(-1+rnd(2)),126,bullet.dx+(-1+rnd(2)),-rnd(1),turf)
			addparticle(bullet.x+(-1+rnd(2)),126,bullet.dx+(-1+rnd(2)),-rnd(1),turf)
		end
		del(bulletlist,bullet)
	end
end

function updatebullets()
	foreach(bulletlist, updatebullet)
end

function drawbullet(bullet)
	c=8
	th=5+rnd(25)
	if(bullet.t>th) c=9
	if(bullet.t>th*2) c=10
	if(bullet.t>th*3) c=6
--	line(bullet.x,bullet.y,bullet.x-bullet.dx*2,bullet.y-bullet.dy*2,5)
	line(bullet.x,bullet.y,bullet.x-bullet.dx,bullet.y-bullet.dy,5)
--	line(bullet.x,bullet.y,bullet.x-bullet.dx,bullet.y-bullet.dy,c)
	if (bullet.huge) then
 	circ(bullet.x,bullet.y,1,c)
	else
		pset(bullet.x,bullet.y,c)
	end
end

function drawbullets()
	foreach(bulletlist,drawbullet)
end
-->8
-- particles
function initparticles()
	particles={}
end

smoke={
	c={5,6,7},
	ttl=30,
	size={2,2.5,3,3.5},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=false,
	shrink=true
	}
	
exbullet={
	c={5,6,7},
	ttl=20,
	size={.5,1,1.5},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=true
	}
	
puff={
	c={5,6},
	ttl=6,
	size={.5,1},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=false
	}
		
fire={
	c={8,9,10},
	ttl=5,
	size={1,1.5},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=false
	}	

shell={
	c={5},
	ttl=50,
	size={.5},
	fill={0b0000000000000000},
	gravity=true
	}	
	
bigfire={
	c={8,9,10},
	ttl=10,
	size={1.5,2,3},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=false,
	shrink=true
	}
	
chaff={
	c={3,11,13,5,4,8,9,1},
	ttl=30,
	size={1,1.5},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=true
	}

turf={
	c={3,4,11},
	ttl=10,
	size={.5,1},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=true
	}

blood={
	c={8},
	ttl=10,
	size={.5,1},
	fill={0b1010010110100101,0b0000000000000000},
	gravity=true
	}

function addparticle(x,y,dx,dy,pt)
	if(#particles > 200) return
	add(particles,{
		x=x,
		y=y,
		dx=dx,
		dy=dy,
		c=rnd(pt.c),
		ttl=pt.ttl*(.7+rnd(1.3)),
		size=rnd(pt.size),
		fill=rnd(pt.fill),
		gravity=pt.gravity,
		shrink=pt.shrink
		})
end

function updateparticle(p)
	move(p)
	if (p.shrink) then
		if (p.ttl<15) then
			p.size=p.size*.9
		end
	end
	p.ttl-=1
	if(p.gravity==true) p.dy=p.dy+.05
	if (p.x < 0) or
		(p.x > 127) or
		(p.y < 0) or
		(p.y > 127) or
		(p.ttl < 0) then
		del(particles,p)
	end
end

function updateparticles()
	foreach(particles,updateparticle)
end

function drawparticle(p)
	fillp(p.fill) 
	circfill(p.x,p.y,p.size,p.c)
	fillp(0b0000000000000000)
end

function drawparticles()
	foreach(particles,drawparticle)
end
-->8
--helicopters
function inithelis()
 helis={}
end

function addheli(elite)
	if(#helis>25) return
		
	e=false
	h=2
	if (elite) then
	 e=true
	 h=5
	end
	
	face=rnd({true,false})
	
	ymin=10	
	ymax=20+min(stage*6,50)
	if(e) ymax=min(ymax,50)
	if(stage<3) ymin=max(20,ymin)

	dxmin=.2
	dxrange=.3
	dxstage=stage/100
	dxmin+=dxstage
	dxrange+=dxstage
	
	dx=dxmin+rnd(dxrange)	

	if (stage < 5) then
		s=1
		s1max=20
		s1min=12
	elseif (stage < 10) then
		s=rnd({1,1,2})
		s1min=10
		s1max=30
	elseif (elite) then
		s=rnd({1,1,2})
		s1min=6
		s1max=35
	else
		s=rnd({1,2})
		s1min=6
		s1max=40
	end
	
	if(elite or s==2) dx=dx/2
	dx=max(dxmin,dx)	

	s1=flr(s1min+rnd(s1max))
	s2=ceil(120-s1min-rnd(s1max))
	
	if (stage<=2) then
		if (face) then
  	s2=-100
	 else
		 s1=-100
		end
	end

	heli={
		x=-8,
		y=ymin+rnd(ymax-ymin),
		dx=dx,
		dy=0,
		hitbox={x=-7,y=0,w=13,h=8},
		f=face,
		h=h,
		s=s,
		s1=s1,
		s2=s2,
		elite=e,
		glow=false,
		tailframe=0,
		bladeframe=0
	}
	if(face) then
		heli.x=135
		heli.dx=-heli.dx
	end
	add(helis,heli)
end

function checkbulletandheli(heli,bullet)
 	if (collidepixel(heli,bullet)) then
		 del(bulletlist,bullet)
			addparticle(r(heli.x,4),r(heli.y,2),bullet.dx*.4,bullet.dy*.4,exbullet)		
			addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
			addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)			
			heli.h-=bullet.damage			
			if (heli.h<0) then
				del(helis,heli)
				if (heli.elite) then
					addscore(250)
				else
					addscore(25)
				end
				sfx(7)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx,0,chaff)
				addparticle(r(heli.x,4),r(heli.y,2),-.3+rnd(.6),-.3+rnd(.6),smoke)
				addparticle(r(heli.x,4),r(heli.y,2),-.3+rnd(.6),-.3+rnd(.6),smoke)
				addparticle(r(heli.x,4),r(heli.y,2),-.3+rnd(.6),-.3+rnd(.6),smoke)
				addparticle(r(heli.x,4),r(heli.y,2),-.3+rnd(.6),-.3+rnd(.6),smoke)
				addparticle(r(heli.x,4),r(heli.y,2),-.3+rnd(.6),-.3+rnd(.6),smoke)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)
				addparticle(r(heli.x,4),r(heli.y,2),heli.dx/2,0,bigfire)
			else
				if(heli.elite) heli.glow=true
				sfx(10)
				heli.dy+=bullet.dy*.02
				heli.dx+=bullet.dx*.02
			end
		end
end

function updateheli(heli)
	move(heli)
	if (heli.s > 0) then
		if (heli.s1==flr(heli.x)) then
			addsoldier(heli.x,heli.y,heli.elite)
			heli.s-=1
			heli.s1=-10
		end
		if (heli.s2==flr(heli.x)) then
			addsoldier(heli.x,heli.y,heli.elite)
			heli.s-=1
			heli.s2=200
		end
	end

	if (heli.x < -8) or
		(heli.x > 135) or
		(heli.h < 0) then
		del(helis,heli)
	end
	if(
		(heli.y > 100) and
		(heli.dy >0)) then
		heli.dy=0
	end
	heli.tailframe+=1
	heli.bladeframe+=1
	if(heli.tailframe>5) heli.tailframe=0
	if(heli.bladeframe>3) heli.bladeframe=0
	for b in all (bulletlist) do
	 checkbulletandheli(heli,b)
	end
end

function updatehelis()
	foreach(helis,updateheli)
end


function drawheli(heli)
	if (heli.elite) then
		if (heli.glow) then
			pal(3,9)
			pal(11,10)
			heli.glow=false
		else
			pal(3,2)
			pal(11,8)
		end
	end
	if (heli.f) then
		-- left
		spr(16,heli.x-8,heli.y,1,1,not heli.f)
		spr(17,heli.x,heli.y,1,1,not heli.f)
		spr(48+heli.tailframe,heli.x,heli.y)
		spr(54+heli.bladeframe*2,heli.x-8,heli.y)
		spr(55+heli.bladeframe*2,heli.x,heli.y)
	else
		-- right
		spr(17,heli.x-8,heli.y,1,1,not heli.f)
		spr(16,heli.x,heli.y,1,1,not heli.f)
		spr(48+heli.tailframe,heli.x-12,heli.y)
		spr(54+heli.bladeframe*2,heli.x-6,heli.y)
		spr(55+heli.bladeframe*2,heli.x+2,heli.y)
	end
	pal()
end

function drawhelis()
	foreach(helis,drawheli)
end
-->8
--soldiers

function initsoldiers()
	soldiers={}
	sstate=
		{
		falling=1,
		flying=2,
		splatting=3,
		standing=4,
		shooting=5,
		cheering=6,
		jumping=7
		}
	
end


function addsoldier(x,y,elite)
	if(#soldiers > 25) return
	e=false
	h=1
 if (elite) then
		e=true
		h=10
	end
	ds=1.2
	if (stage > 5) then
		ds=1.7
	end
	if (gamestatus==gstatus.playing) then
	add(soldiers,{
		x=x,
		y=y,
		f=(x>65),
		dx=0,
		dy=0,
		hitbox={x=2,y=0,w=4,h=7},
		chute=true,
		state=sstate.falling,
		elite=e,
		h=h,
		glow=false,
		dropspeed=ds,
		tick=0
		})
	end
end

function updatesoldier(soldier)
	soldier.tick+=1
	soldier.glow=false
	move(soldier)
	if (soldier.state == sstate.falling) then
		soldier.dy+=.05
		if (soldier.dy>soldier.dropspeed) then
			soldier.state=sstate.flying
			soldier.tick=0
			soldier.dy=.1
		end
		if (soldier.tick > 10) then
			soldier.tick=0
		end
	elseif (soldier.state==sstate.flying) then
		soldier.dy=min(soldier.dy+.01,.2)
		if (soldier.y>119) then
			soldier.state=sstate.standing
			soldier.tick=0
		end
	elseif (soldier.state==sstate.splatting) then
		soldier.dy+=.05
		if (soldier.y > 119) then
		 del(soldiers,soldier)
		 sfx(14)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),turf)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),turf)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),turf)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),turf)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),blood)
			addparticle(soldier.x+(-.5+rnd(1)),126,(-1+rnd(2)),-rnd(1),blood)
		end
				if (soldier.tick > 10) then
			soldier.tick=0
		end
	elseif (soldier.state==sstate.standing) then
		soldier.dx=0
		soldier.dy=0
		ttshoot=100
		if(stage>5)ttshoot=75
		if(stage>10)ttshoot=50
		if(soldier.elite)ttshoot=ttshoot*2
		if (gamestatus==gstatus.pausing) then
			soldier.state=sstate.cheering
		elseif (soldier.tick > ttshoot) then
			soldier.state=sstate.shooting
			soldier.tick=-flr(rnd(3))
			ff=3
			if (soldier.f) then
				ff=-3
			end
			addparticle(soldier.x+4,soldier.y+3,ff,0,fire)
			damagebase(1)
			sfx(6)
		end
	elseif (soldier.state==sstate.shooting) then
		soldier.dy=0
		if (soldier.tick > 10) then
			soldier.state=sstate.standing
			soldier.tick=0
		end
	elseif (soldier.state==sstate.cheering) then
		soldier.dy=0
		if (soldier.tick > 15) then
			soldier.state=sstate.jumping
			soldier.tick=0
		end
	elseif (soldier.state==sstate.jumping) then
		soldier.dy=0
		if (soldier.tick > 10) then
			soldier.state=sstate.cheering
			soldier.tick=0
		end
	end
	screen={x=0,y=0,hitbox={x=3,y=3,w=124,h=124}}
	if (not collide(soldier,screen)) then
		del(soldiers,soldier)
	end
	for b in all (bulletlist) do
	 checkbulletandsoldier(soldier,b)
	end

end


function checkbulletandsoldier(soldier,bullet)
	if (collidepixel(soldier,bullet)) then
		del(bulletlist,bullet)
		soldier.h-=bullet.damage
		addparticle(r(soldier.x,4),r(soldier.y,2),bullet.dx*.4,bullet.dy*.4,exbullet)		
		if (soldier.elite) then
			soldier.dx+=bullet.dx*.05
			soldier.dx=max(soldier.dx,-.2)
			soldier.dx=min(soldier.dx,.2)
			soldier.dy+=bullet.dy*.05
			soldier.glow=true
			sfx(13)
		end
	end
	if (soldier.h<=0)then
		sfx(14)
		del(soldiers,soldier)
		addparticle(r(soldier.x,4),r(soldier.y,2),soldier.dx+bullet.dx/7,soldier.dy+bullet.dy/7,chaff)
		addparticle(r(soldier.x,4),r(soldier.y,2),soldier.dx+bullet.dx/5,soldier.dy+bullet.dy/5,bigfire)			
		addscore(2)
		if (soldier.elite) then
			addscore(15)
		end
	elseif (soldier.state==sstate.flying) then
		chutebox={x=soldier.x,y=soldier.y-6,hitbox={x=1,y=1,w=5,h=4}}
		if (collidepixel(chutebox,bullet))	then
			addparticle(r(soldier.x,4),r(soldier.y,2),bullet.dx*.4,bullet.dy*.4,exbullet)		
			soldier.state=sstate.splatting
			soldier.tick=0
			soldier.dy=0
			addscore(2)
			sfx(6)
			sfx(15)
		end
	end
end

function updatesoldiers()
	foreach(soldiers,updatesoldier)
end

function drawsoldier(soldier)
--	line(64,64,soldier.x,soldier.y,5)

	if (soldier.elite) then
		pal(3,2)
		pal(11,8)
	end
	if (not soldier.elite) and
		((soldier.x > 40) and
		 (soldier.x < 80)) then
		pal(3,5)
		pal(11,6)		 
	end
 if (soldier.state == sstate.falling) then
		fr=44
		if (soldier.tick>5) then
			fr=46
		end
		spr(fr,soldier.x,soldier.y,1,1,soldier.f)
	elseif (soldier.state == sstate.flying) then
		spr(43,soldier.x,soldier.y,1,1,soldier.f)
		spr(12,soldier.x,soldier.y-5,1,1,soldier.f)
	elseif (soldier.state==sstate.splatting) then
		fr=44
		if (soldier.tick>5) then
			fr=46
		end
		spr(fr,soldier.x,soldier.y,1,1,soldier.f)
	elseif (soldier.state==sstate.standing) then
		spr(41,soldier.x,soldier.y,1,1,soldier.f)
	elseif (soldier.state==sstate.shooting) then
		spr(42,soldier.x,soldier.y,1,1,soldier.f)
	elseif (soldier.state==sstate.cheering) then
		spr(62,soldier.x,soldier.y,1,1,soldier.f)
	else
		spr(63,soldier.x,soldier.y,1,1,soldier.f)
	end
--	print (soldier.x,soldier.x,soldier.y-8)
	if (soldier.glow) then
		pal(3,9)
		pal(11,10)
		spr(31,soldier.x,soldier.y,1,1,soldier.f)
	end
	pal()
end

function drawsoldiers()
	foreach (soldiers,drawsoldier)
end
__gfx__
0000000000000000000000000000000000000000288228820066660000033000000330000cc0cc0000c000000000000000666600000000000000000000000000
00000000000000000000000000000000000000008ee8888806666660000bf000000bf0000c0c0c0006c0000000000990066dd660005665000003300000000000
00700700000000000000000000000000000000008e888888665005660f0b30f000fb3f0000ccc00006c0000000000f9065dddd56066dd660000bf00000000000
0007700000d8e00000d880000000000000000000888888886050050600333300003333000ccccc0066006600000000a46d5dd5d6065dd560005b555500000000
0007700000d8e00000d8800000000055550000002888888250055005000b5000000b50000ccccc0044444400000009945050050500500500005333f000000000
0070070000d0000000d000000000056666500000028888200500005000b5b50000b5b5000ccccc00545545000000aa940550055000500500000b500000000000
0000000000d0000000d0000000005666666500000028820000500500053003500030030000ccc0000400400000009444005005000050050000b5b00000000000
0000000000d0000000d00000000055555555000000022000000000000000000000000000000c0000040040000009940400000000000000000300300000000000
00000000000000000000000705d6666666666d500000000000eeee0000aaaa00000330000000000000000000000220000006600000099000000dd00000a99a00
0000000d00000000056665665666666666666665000000000e7788200a779940000bf00000033000000000000008f0000007f000000af0000006f0000a9009a0
001c3bbb500003bb666e66666666666666dddd6600c0c000e77e8822a77a99440f3b30f0000bf000000000000f2820f00f6760f00f9a90f00fd6d0f0a900009a
1ccc3bb3bbbbbbb366888655d665566556d55d6d000c0000e7e88822a7a9994400533300005b555500000000005222000056660000499900005ddd0090000009
bcc3bb33bbbb3333566266666665566556d55d6600ccc000e8888222a9999444005b5000005333f0000000000058500000575000004a400000565000a000000a
033333353335000005555566d66dd66dd6d55d6d00ccc000e8882202a999440400b5b500000b500000000000008585000075750000a4a4000065650099000099
0000500500000000000000066666666666d55d6600ccc00002820020049400400030030000b5b0000000000000200200006006000090090000d00d000a9009a0
00dddddddd000000000000006666666666d55d66001c000000222200004444000000000000300300000000000000000000000000000000000000000000aaaa00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003300000033000000330000003300000033000
0000000000000000000000000000000000000000000000570000000000000000000055000003300000033000000bf000000bf000000ff000000fb0000f0bf0f0
000000b00000b000000003b0000000000000000000000576000000000000000000057600000bf000000bf0000f3b30f00f3b3000003b3000003b30f0003b3300
00003bb0000b3000000bbb000000000001dc677777777766000c67000077000000576600005b55550055555000533300005333000f3333f00f53330000533000
0003bb3000b33b0000bb3300000000005dc676ddddd66d2200067600006dd000006d2000005333f000533f00005b5000005b50f0005b5000000b5000005b5000
0033330000035000000500000000000015dddd666665d820000dd0000006600000d50000000b5000000b500000b5b50000b5b50000bbb00000b5b00000b5b500
00005000000000000000000000000000000000000000000000000000000000000000000000b5b00000b5b0000030030000300300003030000300300000300300
00000000000000000000000000000000000000000000000000000000000000000000000000300300003003000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006666665555555000006666555550000055555566666660000055556666600000000000000033000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000330000f0bf0f0
0000700000000700000000700000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000bf000003b3300
0000065000000650000000600000056000000567000066500000000000000000000000000000000000000000000000000000000000000000003b330000533000
00000560000005600000060000000650000076500000056600000000000000000000000000000000000000000000000000000000000000000f5330f0005b5000
0000000700000070000007000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000005b500000b5b500
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b5b50000300300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030030000000000
000000000000000000000000000000000000000000000000000000000000000000005cc00000000000005cc00000000000005cc0000000000000000000000000
00000000000000000000000000000000000000000000000000000000005ccc88ccccd660005cacacacccd660005cccccccccd660000000000000000000000000
000000000000000000000000000000000000000000000000000000005cccc8888ccc6dd05ccc95959ccc6dd05cccacacaccc6dd0000000000000000000000000
00000000000000000000000000000000000000000000000000000000d66668888666d550d66695959666d550d66696969666d550000000000000000000000000
000000000000000000000000000000000000000000000000000000005d3d3d223d3dddd05d3d42424d3dddd05d3d4d4d4d3dddd0000000000000000000000000
000000000000000000000000000000000000000000000000000000000053ddd3ddd3dd300053ddd3ddd3dd300053ddd3ddd3dd30000000000000000000000000
000000000000000000000000000000000000000000000000000000000000055550005dd00000055550005dd00000055550005dd0000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000ddd5000000000000ddd5000000000000ddd50000000000000000000000000000000
0000000000000000000057700000000000005cc00000000000005cc0000000000000000000000000000000000000000000000000000000000000000000000000
000000000057777777776770005ccc8cccccdcc0005ccc8cccccd660000000000000000000000000000000000000000000000000000000000000000000000000
0000000057777777777776605ccc88888ccccdd05ccc88888ccc6dd0000000800000000000000080000000000000008000000000000000000000000000000000
000000006777777777776550dcccc888ccccd550d66668886666d550000088888000000000008888800000000000888880000000000000000000000000000000
0000000056666666666666605dddd2d2ddddddd05d3d32323d3dddd0000008880000000000000888000000000000088800000000000000000000000000000000
000000000056666666666660005dddddddddddd00053ddd3ddd3dd30000008080000000000000808000000000000080800000000000000000000000000000000
0000000000000000000056600000055550005dd00000055550005dd0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000ddd5000000000000ddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000080000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000008888800000000000888880000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000888000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000808000000000000080800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000670600760056075057075067776705607650570775067076000000000000000000000000000000000000000000000000000000000000000
00000000000000000770760770077067077076077767707607760670777077077000000000000000000000000000000000000000000000000000000000000000
00000000000000000760770670077000077077000000007700770670000077000000000000000000000000000000000000000000000000000000000000000000
00000000000000000760600670077000077077000760007707770770000077077000000000000000000000000000000000000000000000000000000000000000
00000000000000000770000670067000076076000770007706770770077076077000000000000000000000000000000000000000000000000000000000000000
00000000000000000770000670067000076076000770007700770770067076000000000000000000000000000000000000000000000000000000000000000000
00000000000000000770000770067076076076000770007700670760677076076000000000000000000000000000000000000000000000000000000000000000
00000000000000000660000670057075057065000760006700770570675077077000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555666666600000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c3bbb500073bb000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001ccc3bb3bbbbb653000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bcc3bb33bbbb3563000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333333533350007000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500500000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000067060076005607505707506777670560765057077506707600000000000000000000000000000000000000000
00000000000000000000000000000000000000077076077007706707707607776770760776067077707707700000000000000000000000000000000000000000
00000000000000000000000000000000000000076077067007700007707700000000770077067000007700000000000000000000000000000000000000000000
00000000000000000000000000000000000000076060067007700007707700076000770777077000007707700000000000000000000000000000000000000000
00000000000000000000000000000000000000077000067006700007607600077000770677077007707607700000000000000000000000000000000000000000
00000000000000000000000000000000000000077000067006700007607600077000770077077006707600000000000000000000000000000000000000000000
00000000000000000000000000000000000000077000077006707607607600077000770067076067707607600000000000000000000000000000000000000000
00000000000000000000000000000000000000066000067005707505706500076000670077057067507707700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000777070700000777077707770000077700770707077707070777000000000000000000000000000000000000000
00000000000000000000000000000000000000757575750000075507557775000075757075757575757575755500000000000000000000000000000000000000
00000000000000000000000000000000000000770577750000075007507575000077057575757577057705770000000000000000000000000000000000000000
00000000000000000000000000000000000000757005750000075007507575000075707575757575707570755000000000000000000000000000000000000000
00000000000000000000000000000000000000777577750000775077707575000077757705077575757575777000000000000000000000000000000000000000
00000000000000000000000000000000000000055505550000055005550505000005550550005505050505055500000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ccc00000ccc0ccc00cc00cc00000ccc00000c0c0ccc0ccc00cc0ccc00cc0cc0000000000000000000000000000000000
00000000000000000000000000000000c1c10000c1c10c11c011c0c10000c1c10000c1c1c111c1c1c0110c11c0c1c1c000000000000000000000000000000000
00000000000000000000000000000000ccc10000ccc10c10c100c1c1ccc0ccc10000c1c1cc00cc01ccc00c10c1c1c1c100000000000000000000000000000000
00000000000000000000000000000000c1c10000c1110c10c100c1c10111c1c10000ccc1c110c1c001c10c10c1c1c1c100000000000000000000000000000000
00000000000000000000000000000000c1c10000c100ccc00cc0cc010000ccc100000c11ccc0c1c1cc01ccc0cc01c1c100000000000000000000000000000000
00000000000000000000000000000000010100000100011100110110000001110000001001110101011001110110010100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000cc0ccc000000cc0ccc0ccc00cc0ccc0ccc00cc0ccc000000c00cc00ccc0ccc0cc000c000000000000000000000000000000
0000000000000000000000000000c0c1c1110000c011c1c1c1c1c0c10c11c1c1c011c1110000c0100c10c1c1c1c10c1000c00000000000000000000000000000
0000000000000000000000000000c1c1cc000000ccc0ccc1cc01c1c10c10ccc1c100cc000000c1000c10ccc1ccc10c1000c10000000000000000000000000000
0000000000000000000000000000c1c1c110000001c1c1c1c1c0c1c10c10c1c1c1c0c1100000c1000c1001c1c1c10c1000c10000000000000000000000000000
0000000000000000000000000000cc01c1000000cc01c1c1ccc1cc010c10c1c1ccc1ccc000000c00ccc000c1ccc1ccc00c010000000000000000000000000000
00000000000000000000000000000110010000000110010101110110001001010111011100000010011100010111011100100000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000ccc0ccc0ccc00cc00cc00000c0c00000ccc00cc000000cc00cc0cc00ccc0ccc0cc00c0c0ccc000000000000000000000000000
00000000000000000000000000c1c1c1c1c111c011c0110000c1c100000c11c0c10000c011c0c1c1c00c110c11c1c0c1c1c11100000000000000000000000000
00000000000000000000000000ccc1cc01cc00ccc0ccc000000c0100000c10c1c10000c100c1c1c1c10c100c10c1c1c1c1cc0000000000000000000000000000
00000000000000000000000000c111c1c0c11001c101c10000c0c000000c10c1c10000c100c1c1c1c10c100c10c1c1c1c1c11000000000000000000000000000
00000000000000000000000000c100c1c1ccc0cc01cc010000c1c100000c10cc0100000cc0cc01c1c10c10ccc0c1c10cc1ccc000000000000000000000000000
00000000000000000000000000010001010111011001100000010100000010011000000011011001010010011101010011011100000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000555500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000005666650000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000056666665000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000005d6666666666d5000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000566666666666666500000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006666666666dddd6600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000d665566556d55d6d00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006665566556d55d6600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000d66dd66dd6d55d6d00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006666666666d55d6600000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000006666666666d55d6600000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000012000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000003040200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000013150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001001d1a7001e7001b730287001a730247001f7001c700177500b71006710027101871000700007001a75000710187500071000700007000070019750007000070000000167500000000000000000000000000
00010000344502d4502845024450204501e4501845015450114502b550225501c550185501555013550105500e5400c5400b53007520045100255000550005500250001500065000550002500005000050002600
00030000186502d650126500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400003a0503305028050190500d050070500105000050010500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003a750357502e750277502175019750127500a750037500075000750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000046500c640126201762013620086400165000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000096100c6100d610096100361031600000000000000000000000000000000000000000027600000000000000000000000000000000006300f620000000000000000000000000000000000000000000000
00020000396103963038610346102e61028610226201d61018610156000e610066100061000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003565037650396503a6503965038650376503665034650316502d6502965025650206501e6501b65019640176401564013640116300f6300e6300c6200a62009620086200762005620036100261001610
000100002f61000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003321000700007000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001461000610106101361002610086100b61005610006100d6100c610026100361007610026100c610026100261017610026100e610016100c6100361003610086100b61000610056101f6100261002610
000100001b720284200c620177203c3201a7203c3201c7102d4101461035710367100e6100e6000f6002560014600146001460015600000000000000000000000000000000000000000000000000000000000000
000300003b41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002d520315203252032520305202d5202b52024520215201f5101d5101b5101851015510115100e5100b510095100751005510045100155001500005000050000500005000050000500005000050000500
000200000e2300e2100c2100520004200012000420001200021000110001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000a4500c4500e45010450154501a4501e45023450284502b4501045011450124501345016450174501b4501f45024450284502d45014450184501c4501f4302242026420294102c4102f4103440038400
000100002265024620256202562025620266202665027600286002a4502a4502a450145002a6002a6002a6502b6202b6202b6202c6202c6302c6302c6600000000000000002a4502a4502a4502a4502a4502a450
000100001a4201d4202042022420244302343022430204302042000000000002142022420234302443025430264302742028420294202b4102d4102e4202f4200000000000000000000000000000000000000000
000100003d6102f620006000560019610376100000000000000001561000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000025500455004550055500755008550095500a5500c5500e5500f55010550125501455016550185501b5501f55022550295502f5503155000000000000000000000000000000000000000000000000000
__music__
00 49424344

