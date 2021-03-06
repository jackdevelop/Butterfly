--[[
战斗数据模型
]]
local ObjectFactory = require("app.gameObject.ObjectFactory")

local FightModel = class("FightModel")




function FightModel:ctor(controller,levelData)
	self.objects_           = {}
    self.objectsByClass_    = {}
    self.heroObject_  		= nil;
    self.nextObjectIndex_   = 1
    
    
    self.controller_ = controller;
    self.batch_ = controller.scene_:getBatchLayer();
    self.debugLayer_ =  controller.scene_:getDebugLayer();
    
--    --拆分数据
--    self.levelData_ = levelData;
--    self.width_ = levelData.width;
--    self.height_ = levelData.height;
end











--[[--

创建新的对象，并添加到地图中

]]
function FightModel:newObject(classId, state, id)
    if not id then
        id = string.format("%s:%d", classId, self.nextObjectIndex_)
        self.nextObjectIndex_ = self.nextObjectIndex_ + 1
    end

    local object = ObjectFactory.newObject(classId, id, state, self)
    object:resetAllBehaviors()

    -- validate max object index  记录最大的对象个数
    local index = object:getIndex()
    if index >= self.nextObjectIndex_ then
        self.nextObjectIndex_ = index + 1
    end

    -- add object
    self.objects_[id] = object
    if not self.objectsByClass_[classId] then
        self.objectsByClass_[classId] = {}
    end
    local len = #self.objectsByClass_[classId] + 1;
    self.objectsByClass_[classId][len] = object
	

    -- validate object
--    if self.ready_ then
--        object:validate()
--        if not object:isValid() then
--            echoInfo(format("FightModel:newObject() - invalid object %s", id))
--            self:removeObject(object)
--            return nil
--        end
--        -- create view
--        if self:isViewCreated() then
            object:createView(self.batch_, self.marksLayer_, self.debugLayer_)
            object:updateView()
--        end
--    end

    return object
end

--[[--

从地图中删除一个对象

]]
function FightModel:removeObject(object)
    local id = object:getId()
    assert(self.objects_[id] ~= nil, format("FightModel:removeObject() - object %s not exists", tostring(id)))

    self.objects_[id] = nil
    self.objectsByClass_[object:getClassId()] = nil
    if object:isViewCreated() then object:removeView() end
end

--[[--

从地图中删除指定 Id 的对象

]]
function FightModel:removeObjectById(objectId)
    self:removeObject(self:getObject(objectId))
end

--[[--

检查指定的对象是否存在

]]
function FightModel:isObjectExists(id)
    return self.objects_[id] ~= nil
end

--[[--

返回指定 Id 的对象

]]
function FightModel:getObject(id)
    assert(self:isObjectExists(id), string.format("FightModel:getObject() - object %s not exists", tostring(id)))
    return self.objects_[id]
end

--[[--

返回地图中所有的对象

]]
function FightModel:getAllObjects()
    return self.objects_
end

--[[--

返回地图中特定类型的对象

]]
function FightModel:getObjectsByClassId(classId)
    -- dump(self.objectsByClass_[classId])
    return self.objectsByClass_[classId] or {}
end




--[[--

返回地图中的主角对象

]]
function FightModel:getFocusObject()
    return self.focusObject_;
end
function FightModel:setFocusObject(object)
	if self.focusObject_ == object then return end
	
	if 	self.focusObject_ then
		self.focusObject_:setFocus(false);
	end
	object:setFocus(true);
    self.focusObject_ = object;
    
    
    local mapCamera = self.controller_.scene_:getCamera()
	mapCamera:setFocus(object)
end

return FightModel
