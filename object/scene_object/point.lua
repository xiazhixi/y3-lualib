---@alias Point.HandleType py.FPoint

---@class Point
---@field handle Point.HandleType
---@field res_id? integer
---@overload fun(py_point: Point.HandleType): self
---@overload fun(x: number, y: number, z?: number): self
local M = Class 'Point'

M.type = 'point'

---@param py_point Point.HandleType
---@return self
function M:constructor(py_point)
    self.handle = py_point
    return self
end

---@param x number
---@param y number
---@param z? number
---@return Point
function M:alloc(x, y, z)
    return M.create(x, y, z)
end

---@private
M.map = {}

---@param res_id integer
---@return Point
function M.get_point_by_res_id(res_id)
    if not M.map[res_id] then
        local py_point = GameAPI.get_point_by_res_id(res_id)
        local point = M.get_lua_point_from_py(py_point)
        point.res_id = res_id
        M.map[res_id] = point
    end
    return M.map[res_id]
end

---根据py对象创建点
---@param py_point Point.HandleType
---@return Point
function M.get_lua_point_from_py(py_point)
    local point = New 'Point' (py_point)
    return point
end

y3.py_converter.register_py_to_lua('py.FPoint', M.get_lua_point_from_py)
y3.py_converter.register_lua_to_py('py.FPoint', function (lua_value)
    return lua_value.handle
end)

---设置碰撞
---@param is_collision_effect boolean  碰撞是否生效
---@param is_land_effect boolean  地面碰撞开关
---@param is_air_effect boolean  空中碰撞开关
function M:set_collision(is_collision_effect, is_land_effect, is_air_effect)
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    GameAPI.set_point_collision(self.handle, is_collision_effect, is_land_effect, is_air_effect)
end

---获取地图在该点位置的碰撞类型 
---@return integer
function M:get_ground_collision()
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return GameAPI.get_point_ground_collision(self.handle)
end

---获取地图在该点位置的视野类型
---@return integer
function M:get_view_block_type()
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return GameAPI.get_point_view_block_type(self.handle)
end

---点的x坐标
---@return number
function M:get_x()
    local x = GlobalAPI.get_vector3_x(self.handle):float()
    return x
end

---点的y坐标
---@return number
function M:get_y()
    local y = GlobalAPI.get_vector3_y(self.handle):float()
    return y
end

---点的z坐标
---@return number
function M:get_z()
    local z = GlobalAPI.get_vector3_z(self.handle):float()
    return z
end

---坐标转化为点
---@param x number 点X坐标
---@param y number 点Y坐标
---@param z? number 点Z坐标
---@return Point
function M.create(x, y, z)
    local py_point = GlobalAPI.coord_to_point(Fix32(x), Fix32(y), Fix32(z or 0))
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return M.get_lua_point_from_py(py_point)
end

---点向方向偏移
---@param point Point 点
---@param direction number 偏移方向点
---@param offset number 偏移量
---@return Point
function M.get_point_offset_vector(point, direction, offset)
    local py_point = GlobalAPI.get_point_offset_vector(point.handle, Fix32(direction), Fix32(offset))
    -- TODO 见问题2
    ---@diagnostic disable-next-line: param-type-mismatch
    return M.get_lua_point_from_py(py_point)
end


---路径中的点
---@param path table 目标路径
---@param index integer 索引
---@return Point
function M.get_point_in_path(path,index)
    local py_point = GlobalAPI.get_point_in_route(path.handle, index)
    return M.get_lua_point_from_py(py_point)
end

return M
