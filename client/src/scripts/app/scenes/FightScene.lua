--[[
战斗场景
]]
local BaseScene = require("engin.mvcs.view.BaseScene")
local FightScene = class("FightScene", BaseScene)


	
function FightScene:ctor()
	
--	param.sceneSound = GameSoundProperties[levelData.sceneSound](); --GameSoundProperties.bg_sound();
--	param.backgroundImageName = levelData.backgroundImageName;
----	param.width = levelData.width;
----	param.height = display.height;
--	param.batchNodeImage = levelData.batchNodeImage;
	FightScene.super.ctor(self)
--    GameUtil.spriteFullScreen(self.backgroundSprite_)
--    http://gabrielecirulli.github.io/2048/
    
    
      --控制器
    local FightController = require("app.controllers.FightController")
	self.sceneController_ = FightController.new(self);
	
	
    
	self:initView();
end





function FightScene:initView()
	GAME_ISFIRST = true
	GAME_SPEED = 2.5 --前进的速度
	GAME_DROP_SPEED = 0.3 --重力加速度
	GAME_FLY_SPEED = 7 --点击飞行时的瞬间速度
	GAME_EARTH_HEIGHT = 60 --土的高度
	GAME_BLOCK_HEIGHT = 130 --官道的高度
	GAME_BLOCK_INTERVAL = 300 --官道距离
	GAME_BLOCK_HEIGHT_RANGE_MIN = display.height/4+50
	GAME_BLOCK_HEIGHT_RANGE_MAX = GAME_BLOCK_HEIGHT_RANGE_MIN+190

	GAME_STATE = 0 --0 等待开始 1 战斗中 2 死亡，等待结束


	
	
	
	local batch = self:getBatchLayer();
	local sky = CCLayerColor:create(ccc4(139,184,234,255))
	batch:addChild(sky)

	self.block = {} --水管  碰撞管
	self.blockPos = {} --水管位置信息
	for i=1,5 do
		local sprite1 = cc.ui.UIImage.new("res/image/block.png")
        :align(display.TOP_LEFT)
        :addTo(batch)

		local sprite2 = cc.ui.UIImage.new("res/image/block.png")
        :align(display.BOTTOM_LEFT)
        :flipY(true)
        :addTo(batch)
        
		local tab = {sprite1,sprite2}
		self:setPosX(tab,150+i*GAME_BLOCK_INTERVAL)
		self:setPosY(tab,math.random(GAME_BLOCK_HEIGHT_RANGE_MIN,GAME_BLOCK_HEIGHT_RANGE_MAX))
		self.block[i] = tab
	end

	local earth = CCLayerColor:create(ccc4(240,180,110,255),display.width,GAME_EARTH_HEIGHT)
	batch:addChild(earth,3)


	
        
	self.birds = display.newSprite("res/image/birds.png",0,display.height)
	batch:addChild(self.birds)


	
	
    
    
	self.mil = ui.newTTFLabel({
		text = "0",
		color = display.COLOR_WHITE,
		textAlign = display.LEFT_CENTER,
		textValign = display.LEFT_CENTER,
		x = 50,
		y = display.top - 30,
		size = 24
	})
	batch:addChild(self.mil)
	
end





function FightScene:setPosX( tab, x )
	tab[1]:setPositionX(x)
	tab[2]:setPositionX(x)
end
function FightScene:setPosY( tab , y )
	tab[1]:setPositionY(y-GAME_BLOCK_HEIGHT/2)
	tab[2]:setPositionY(y+GAME_BLOCK_HEIGHT/2)
end




















----[[--
--	触摸事件 
--]]
function FightScene:onTouch(event, x, y)
	if event == "began" then
		if GAME_STATE == 1 then
			self:fly()
		end
		return true
	elseif event == "ended" then
		if GAME_STATE == 0 then
			self:initialize()
		end
	end
end



function FightScene:fly( )
	self.birdSpeedY = GAME_FLY_SPEED

	local t = math.random()*3

	self.birds:setRotation(0)
	self.birds:stopAllActions()
	if t <= 1 then
		local rotate = CCRotateBy:create(0.8,360)
		self.birds:runAction(rotate)
	elseif t <= 2 then
		local rotate = CCRotateBy:create(0.8,1080)
		self.birds:runAction(rotate)
	end
end
















function FightScene:initialize()
	GAME_STATE = 1
	self.birds:setPosition(ccp(0,display.height))
	self.birds:setRotation(0)
	self.birdSpeedY = 0
	self.blockPos = {}
	self.flyMil = 0
	self:beginFly()
	if not GAME_ISFIRST then
		for i=1,5 do
			self:setPosX(self.block[i],150+i*GAME_BLOCK_INTERVAL)
			self:setPosY(self.block[i],math.random(GAME_BLOCK_HEIGHT_RANGE_MIN,GAME_BLOCK_HEIGHT_RANGE_MAX))
		end
	end
	GAME_ISFIRST = false
	self:unscheduleUpdate();
	self:scheduleUpdate(function(dt) self:tick(dt) end)
end

function FightScene:tick(dt)
	if GAME_STATE ~= 1 then return end

	self.blockPos = {}
	if self.birds:getPositionX() < 200 then
		self.birds:setPositionX(self.birds:getPositionX() + GAME_SPEED)
	else
		for i,v in ipairs(self.block) do
			local newX = v[1]:getPositionX() - GAME_SPEED
			if newX < -100 then
				newX = newX + 5*GAME_BLOCK_INTERVAL
				self:setPosY(v,math.random(GAME_BLOCK_HEIGHT_RANGE_MIN,GAME_BLOCK_HEIGHT_RANGE_MAX))
			end
			self.blockPos[i] = newX
			self:setPosX(v,newX)
		end
	end
	self.birdSpeedY = self.birdSpeedY - GAME_DROP_SPEED
	self.birds:setPositionY(self.birds:getPositionY()+self.birdSpeedY)
	self.flyMil = self.flyMil + GAME_SPEED/10
	self.mil:setString(toint(self.flyMil).." m")

	if self:checkBirdBlock() then
		self:lose()
	end
end

















function FightScene:beginFly( )
	self.birdSpeedY = 0
end

function FightScene:birdDrop(callback)
	self.birds:stopAllActions()
	local x,y = self.birds:getPosition()
	local config = ccBezierConfig:new_local()
	config.controlPoint_1 = ccp(x,y)
	config.controlPoint_2 = ccp(x,y)
	config.endPosition = ccp(x,GAME_EARTH_HEIGHT)
	local bezier = CCBezierTo:create(1,config)
	local call = CCCallFunc:create(callback)
	local seq = CCSequence:createWithTwoActions(bezier,call)
	local rotate = CCRotateTo:create(1,0)
	local spaw = CCSpawn:createWithTwoActions(seq,rotate)
	self.birds:runAction(spaw)
end

function FightScene:lose( )
	self:unscheduleUpdate()
	GAME_STATE = 2
	local function dropCall ( )
		GAME_STATE = 0
	end
	self:birdDrop(dropCall)
end

function FightScene:checkBirdBlock( )
	local x,y = self.birds:getPosition()
	if y<GAME_EARTH_HEIGHT then
		self.birds:setPositionY(GAME_EARTH_HEIGHT)
		self:unscheduleUpdate()
		GAME_STATE = 0
		return false
	else
		for i,v in ipairs(self.blockPos) do
			if x > v-16 and x < v+100 then
				local py = self.block[i][1]:getPositionY()
				if y < py + 15 or y > py + GAME_BLOCK_HEIGHT - 15 then
					return true
				else
					break
				end
			end
		end
		return false
	end
end

return FightScene
