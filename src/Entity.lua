-- Getting folder that contains our src
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")

local lovetoys = require(folderOfThisFile .. 'namespace')
local Entity = lovetoys.class("Entity")

function Entity:initialize(parent, name)
    self.components = {}
    self.eventManager = nil
    self.alive = false
    if parent then
        self:setParent(parent)
    else
        parent = nil
    end
    self.name = name
    self.children = {}
end

-- Sets the entities component of this type to the given component.
-- An entity can only have one Component of each type.
function Entity:add(component, name)
    if not name then name = component.class.name end
    if self.components[name] then
        lovetoys.debug("Entity: Trying to add Component '" .. name .. "', but it's already existing. Please use Entity:set to overwrite a component in an entity.")
    else
        self.components[name] = component
        if self.eventManager then
            self.eventManager:fireEvent(ComponentAdded(self, name))
        end
    end
end

function Entity:set(component, name)
    if not name then name = component.class.name end
    if self.components[name] == nil then
        self:add(component, name)
    else
        self.components[name] = component
    end
end

function Entity:addMultiple(componentList)
    for _, component in pairs(componentList) do
        self:add(component)
    end
end

-- Removes a component from the entity.
function Entity:remove(name)
    if self.components[name] then
        self.components[name] = nil
    else
        lovetoys.debug("Entity: Trying to remove unexisting component " .. name .. " from Entity. Please fix this")
    end
    if self.eventManager then
        self.eventManager:fireEvent(ComponentRemoved(self, name))
    end
end

function Entity:setParent(parent)
    if self.parent then self.parent:getChildren()[self.id] = nil end
    self.parent = parent
    self:registerAsChild()
end

function Entity:getParent()
    return self.parent
end

function Entity:registerAsChild()
    if self.id then self.parent:getChildren()[self.id] = self end
end

function Entity:getChildren()
    return self.children
end

function Entity:get(name)
    return self.components[name]
end

function Entity:has(name)
    return not not self:get(name)
end

function Entity:getComponents()
    return self.components
end

return Entity
