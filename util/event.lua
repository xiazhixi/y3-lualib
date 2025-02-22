---@class Event
---@field private event_name Event.Name
---@field private triggers LinkedTable
---@field private wait_pushing Trigger[]
---@field private wait_poping  Trigger[]
---@overload fun(event_name: string): self
local M = Class 'Event'

---@alias Event.Name string

---@private
M.fire_lock = 0

---@param event_name Event.Name
---@return self
function M:constructor(event_name)
    self.event_name = event_name
    self.triggers = New 'LinkedTable' ()
    self.wait_pushing = {}
    self.wait_poping  = {}
    return self
end

---@param trigger Trigger
function M:add_trigger(trigger)
    if self:is_firing() then
        self.wait_pushing[#self.wait_pushing+1] = trigger
    else
        self.triggers:pushTail(trigger)
    end
end

---@param trigger Trigger
function M:remove_trigger(trigger)
    if self:is_firing() then
        self.wait_poping[#self.wait_poping+1] = trigger
    else
        self.triggers:pop(trigger)
    end
end

---@private
function M:check_waiting()
    if #self.wait_pushing > 0 then
        for _, trigger in ipairs(self.wait_pushing) do
            self.triggers:pushTail(trigger)
        end
        self.wait_pushing = {}
    end
    if #self.wait_poping > 0 then
        for _, trigger in ipairs(self.wait_poping) do
            self.triggers:pop(trigger)
        end
        self.wait_poping = {}
    end
end

---@param ... any
function M:notify(...)
    self.fire_lock = self.fire_lock + 1
    ---@param trigger Trigger
    for trigger in self.triggers:pairs() do
        trigger:execute(...)
    end
    self.fire_lock = self.fire_lock - 1
end

---@param ... any
---@return any, any, any, any
function M:dispatch(...)
    self.fire_lock = self.fire_lock + 1
    ---@param trigger Trigger
    for trigger in self.triggers:pairs() do
        local a, b, c, d = trigger:execute(...)
        if a ~= nil then
            self.fire_lock = self.fire_lock - 1
            self:check_waiting()
            return a, b, c, d
        end
    end
    self.fire_lock = self.fire_lock - 1
    self:check_waiting()
end

---@return boolean
function M:is_firing()
    return self.fire_lock > 0
end
