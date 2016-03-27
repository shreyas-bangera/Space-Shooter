display.setStatusBar(display.HiddenStatusBar)

function main( )
	-- general stuff
	centerX = display.contentCenterX
	centerY = display.contentCenterY

	width = display.contentWidth
	height = display.contentHeight

	-- physics
	local physics = require("physics")
	physics.start()

	--Global Variables
	bullets = 100
	score = 0
	life = 5

	--physics
	local physics = require("physics")
	physics.start()
	physics.setGravity(0,0)

	--sounds
	local shot = audio.loadSound("images/weapon_player.wav")
	local player_explode = audio.loadSound ("images/explosion_player.wav")
	local enemy_explode = audio.loadSound ("images/explosion_enemy.wav")
	local bgSound = audio.loadSound("bg.wav")

	audio.play( bgSound, {loops=-1})
	
	--background Paralax scrolling
	local background1 = display.newImage("images/bg.png")
	background1.x = centerX
	background1.y = centerX

	local background2 = display.newImage("images/bg.png")
	background2.x = centerX
	background2.y = -800

	myListener = function(self, event )
		if (self.y > 1000) then
			self.y = -800
		else
	    	self.y = self.y + 5
	    end
	end
	background1.enterFrame = myListener
	Runtime:addEventListener( "enterFrame", background1 )

	background2.enterFrame = myListener
	Runtime:addEventListener( "enterFrame", background2 )

--Sprite Explosion Animation
	function generateExplosion(xPosition , yPosition)
	    local options = { width = 60,height = 49,numFrames = 6}
	    local explosionSheet = graphics.newImageSheet( "images/explosion.png", options )
	    local sequenceData = {
	     { name = "explosion", start=1, count=6, time=400,   loopCount=1 }
	    }
	    local explosionSprite = display.newSprite( explosionSheet, sequenceData )
	    explosionSprite.x = xPosition
	    explosionSprite.y = yPosition
	    explosionSprite:addEventListener( "sprite", explosionListener )
	    explosionSprite:play()
	    audio.play(player_explode)
	end

	--Remove sprite
	function explosionListener( event )
	     if ( event.phase == "ended" ) then
	        local explosion = event.target 
		    explosion:removeSelf()
		    explosion = nil
	    end
	end

	--score
	scoreText = display.newText("Score : "..score, 10, 8, "Akashi", 18)

	--life
	lifeText = display.newText("Life : "..life, 10, 28, "Akashi", 18)

	--Bottom Wall
	wall = display.newRect(0, height + 300 , 600 , 50 )
	wall:setFillColor(255,255,255)
	physics.addBody(wall, "static")
	wall.type = "wall"

	--Top wall
	topWall = display.newRect(0, -100, 600, 50 )
	topWall:setFillColor(255,255,255)
	physics.addBody(topWall, "static")
	topWall.type = "topWall"

	--Game Controls
	leftArrow = display.newImage("images/left.png")
	leftArrow.x = display.contentWidth - 290
	leftArrow.y = display.contentHeight - 5

	function moveLeft()
		ship.x = ship.x - 8
		if ship.x < 5 then
			ship.x = 5
		end
	end

	leftArrow:addEventListener("touch", moveLeft)

	--- Right Arrow
	rightArrow =  display.newImage("images/right.png")
	rightArrow.x = display.contentWidth -200
	rightArrow.y = display.contentHeight -5

	function moveRight()
		ship.x = ship.x + 8
		if ship.x > display.contentWidth then
			ship.x = display.contentWidth - 5
		end
	end

	rightArrow:addEventListener("touch", moveRight)

	--Shoot Button
	shootBtn = display.newImage("images/fire.png")
	shootBtn.x = display.contentWidth - 40
	shootBtn.y = display.contentHeight - 5

	--Bullets (Lasers)
	function shoot( )
		if (bullets ~= 0) then
			bullets = bullets 
			laserBeam =  display.newImage("images/player_bullet1.png")
			laserBeam.x = ship.x
			laserBeam.y = ship.y - 45
			laserBeam.type = "laser"
			laserBeam.isBullet = true
			physics.addBody(laserBeam, "dynamic", {density = 1, friction = 0});
			transition.to(laserBeam, {time = 1000, x=ship.x, y= -100})
			audio.play(shot)
		end

		--shoot collision
		function laserBeam.collision(self, event)
			if(event.phase == "began") then
				if (event.other.type == "enemy") then
					event.other:removeSelf()
					generateExplosion(event.other.x , event.other.y)
					event.other:removeSelf()
					score = score + 10
					scoreText.text = "Score : "..score
					audio.play(enemy_explode)
				end

				if (event.other.type == "topWall") then
					self:removeSelf( )
				end
			end
		end
		laserBeam:addEventListener( "collision", laserBeam, -1 )

	end
	shootBtn:addEventListener("tap", shoot)

	--enemy
	function enemySpawn()
		function spawn()
				RandomX = math.random(30, display.contentWidth - 20)
				if ( math.random(1,5) == 1 or math.random(1,5) == 2 ) then
					asteroid = display.newImage("images/asteroid.png")
					asteroid.x = RandomX
					asteroid.y = -50
					asteroid.width = 80
					asteroid.height = 80
					asteroid.rotation = math.random(20, 180)
					asteroid.type = "enemy"
					physics.addBody(asteroid, "dynamic", {friction = 0})
					transition.to( asteroid, {time=3000, y= display.contentHeight + 300})
				else
					enemy = display.newImage("images/enemy.png")
					enemy.x = RandomX
					enemy.y = -50
					enemy.width = 60
					enemy.height = 60
					enemy.type = "enemy"
					physics.addBody(enemy, "dynamic", {friction = 0})
					transition.to( enemy, {time=4000, y= display.contentHeight + 300})

					--remove if offscreen 
					function enemy.collision(self, event)
						if(event.phase == "began") then
							if (event.other.type == "wall") then
								self:removeSelf( )
							end
						end
					end
					enemy:addEventListener( "collision", enemy, -1 )

					--enemy shoot
					ebullet = display.newImage("images/bullet1.png")
					ebullet.x = enemy.x 
					ebullet.y = enemy.y + 45
					ebullet.type = "enemy"
					ebullet.isFixedRotation = true
					ebullet.angularVelocity = 0
					physics.addBody(ebullet, "dynamic", {friction = 0, density=1})
					ebullet.isBullet = true

					transition.to( ebullet, {time=1300, y = height + 300})
				end
		end
		timer.performWithDelay(2000, spawn, 0)
	end
	timer.performWithDelay( 2000, enemySpawn, 1)

	--Ship
	ship = display.newImage("images/ship.png")
	ship.x = centerX
	ship.y = display.contentHeight - 70
	ship.width = 90
	ship.height = 90
	physics.addBody(ship, "static", {density = 1, friction = 0, bounce = 0});

	function ship.collision(self,event)
		if(event.phase == "began") then
			if(event.other.type == "enemy") then
				life = life - 1
				lifeText.text = "Live : "..life
				event.other:removeSelf( )
				self.alpha = 0.6;
				transition.to(self, {alpha=1, time=500})
				audio.play(player_explode)
				if(life == 0) then
					self:removeSelf( )
					generateExplosion(self.x , self.y)
					event.other:removeSelf()
					leftArrow:removeEventListener("touch", moveLeft)
					rightArrow:removeEventListener("touch", moveRight)
					shootBtn:removeEventListener("tap", shoot)

					transition.to( leftArrow, {time=1000, y= width + 300} )
					transition.to( rightArrow, {time=1000, y= width + 300} )
					transition.to( shootBtn, {time=1000, y= width + 300} )

					gameover = display.newText("Game Over", centerX,  centerY - 400, 0, 180, "Akashi", 50)
					transition.to( gameover, {time=1000, x = centerX ,y=centerY} )
				end
			end
		end
	end

	ship:addEventListener( "collision", ship, -1 )
end

function splash()
	splashScreen = display.newImage( "images/splash.jpg" )
	splashScreen.height  = 540
    timer.performWithDelay(2000, removeSplash)
end

function removeSplash()
	display.remove(splashScreen)
	splashScreen = nil
	startMenu()
	--main()
end

function startMenu()
	menu = display.newImage("images/menu.png")
	menu.height = display.contentHeight + 100

	startBtn = display.newText("Start", display.contentCenterX -40, display.contentCenterY,"Akashi", 30 )
	startBtn:setFillColor(124, 183, 211)

	creditsBtn = display.newText("Credits", display.contentCenterX -40, display.contentCenterY + 70,"Akashi", 30 )
	creditsBtn:setFillColor(124, 183, 211)

	exitBtn = display.newText("Exit", display.contentCenterX -40, display.contentCenterY + 140,"Akashi", 30 )
	exitBtn:setFillColor(124, 183, 211)

	function startGame()
		display.remove(menu)
		menu = nil
		display.remove(startBtn)
		startBtn = nil
		display.remove(creditsBtn)
		creditsBtn = nil
		display.remove(exitBtn)
		exitBtn = nil
		main()
	end
	startBtn:addEventListener( "touch", startGame )

	function showCredits()
		startBtn.isVisible = false
		creditsBtn.isVisible = false
		exitBtn.isVisible = false

		credits = display.newImage("images/credits1.png", 0, display.contentCenterY + 300)
		transition.to( credits, {time=1000, y=display.contentCenterY + 50, onComplete = function() credits:addEventListener("tap", hideCredits)end})

		function hideCredits()
			transition.to(credits, {time = 1000, y =display.contentWidth + 400, onComplete= function() creditsBtn.isVisible=true startBtn.isVisible=true exitBtn.isVisible=true credits:removeEventListener("tap", hideCredits) display.remove(credits) creditsView=nil end})
		end
	end
	creditsBtn:addEventListener( "touch", showCredits )

	function exitGame()
		os.exit()
	end

	exitBtn:addEventListener( "touch", exitGame )
end


splash()