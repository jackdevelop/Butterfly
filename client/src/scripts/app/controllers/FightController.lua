--[[
战斗控制器
]]


local FightController = class("FightController")


FightController.Left = "FightController.Left"
FightController.Right = "FightController.Right"
FightController.Up = "FightController.Up"
FightController.Down = "FightController.Down"

--[[
战斗控制器 构造函数
@param scene 场景
]]
function FightController:ctor(scene)
	--显示场景
	self.scene_  =  scene; 
	
	--模型
	local FightModel = require("app.model.FightModel")
	self.model_ = FightModel.new(self);
	
	--控制的数据
    self.over_ = false; 
end



return FightController
