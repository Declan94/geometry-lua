-- Geometry 
-- Simple analytic Geometry implemented by lua
-- Created by Declan 2015/12/22

require ('extern')

Geometry = {}

-- support funcs

function Geometry.get_angle(dx, dy)
	local hypo = math.sqrt(dx*dx + dy*dy)
	local a = math.acos(dx / hypo)
	if dy < 0 then
		a = math.pi * 2 - a
	end
	return Geometry.normalize_angle(a)
end

function Geometry.normalize_angle( angle )
	while angle >= math.pi*2 do angle = angle - math.pi * 2 end
	while angle < 0 do angle = angle + math.pi * 2 end
	return angle
end

-------------------------------------------------------------------- 
-- Point 点
--------------------------------------------------------------------

-- x, y
-- ccsprite
-- ccp
Geometry.Point = class("Point", function ( ... )
	local x, y
	if #{...} == 2 then
		x, y = ...
	else
		local sorp = ...
		if sorp.x ~= nil then
			x, y = sorp.x, sorp.y
		else
			x, y = sorp:getPosition()
		end
	end
	return {x=x, y=y}
end)

function Geometry.Point:to_ccp(  )
	return ccp(self.x, self.y)
end

-- 从x轴旋转的角度
function Geometry.Point:get_angle( p )
	if p == nil then return nil end
	local dx, dy = p.x - self.x, p.y - self.y
	return Geometry.get_angle(dx, dy)
end

-- 点到直线距离
function Geometry.Point:dis_to_line( l )
	local c = math.sqrt(l.A*l.A + l.B*l.B)
	local a = math.abs(l.A*self.x + l.B*self.y + l.C)
	return a / c
end

-- 点到点距离
function Geometry.Point:dis_to_point( p )
	local dx, dy = self.x - p.x, self.y - p.y
	return math.sqrt(dx*dx + dy*dy)
end

-- 投影到直线上的垂足
function Geometry.Point:foot_to_line( l )
	local l2 = Geometry.Line.new(self, l.B, -l.A)
	return l2:inter_pt_with_line(l)
end

-- 关于直线的对称点
function Geometry.Point:symmetric_to_line( l )
	local c1 = l.A*l.A+l.B*l.B
	local c2 = l.A*l.A-l.B*l.B
	local x = (-c2*self.x-2*l.A*l.B*self.y-2*l.A*l.C) / c1
	local y = (c2*self.y-2*l.A*l.B*self.x-2*l.B*l.C) / c1
	return Geometry.Point.new(x, y)
end

-------------------------------------------------------------------- 
-- Dot (Point) 有大小的点
-------------------------------------------------------------------- 

-- x, y, r
-- point/ccp/ccsprite, r
Geometry.Dot = class("Dot", function ( ... )
	local d, x, y, p, r
	if #{...} == 3 then
		x, y, r = ...
		d = Geometry.Point.new(x, y)
	else
		pors, r = ...
		d = Geometry.Point.new(pors)
	end
	d.r = r
	return d
end)

-------------------------------------------------------------------- 
-- Line 直线
-------------------------------------------------------------------- 

-- a, b, c
-- point/ccp/ccsprite, point/ccp/ccsprite
-- point/ccp/ccsprite, a, b
Geometry.Line = class("Line", function ( ... )
	local a, b, c
	if #{...} == 2 then
		local p1, p2 = ...
		if p1.__cname ~= "Point" then p1 = Geometry.Point.new(p1) end
		if p2.__cname ~= "Point" then p2 = Geometry.Point.new(p2) end
		a = p1.y - p2.y
		b = p2.x - p1.x
		c = - a*p1.x - b*p1.y
	else
		a, b, c = ...
		if type(a) ~= "number" then
			local p
			p, a, b = ...
			if p.__cname ~= "Point" then p = Geometry.Point.new(p) end
			c = - a*p.x - b*p.y
		end
	end
	return {A=a, B=b, C=c}
end)

-- 给定x得到直线上的点
function Geometry.Line:get_pt_with_x( x )
	if self.B == 0 then return nil end
	local y = - (self.A * x + self.C) / self.B
	return Geometry.Point.new(x, y)
end

-- 给定y得到直线上的点
function Geometry.Line:get_pt_with_y( y )
	if self.A == 0 then return nil end
	local x = - (self.B * y + self.C) / self.A
	return Geometry.Point.new(x, y)
end

-- 获取line和line的交点
function Geometry.Line:inter_pt_with_line( l )
	local coe = (self.A * l.B - l.A * self.B)
	if coe == 0 then 
		return nil end
	local x = (l.C * self.B - self.C * l.B) / coe
	local y = (self.C * l.A - l.C * self.A) / coe
	return Geometry.Point.new(x, y)
end

-- 获取dot和line的交点
function Geometry.Line:inter_pt_with_dot( d )
	local d_d2l = d:dis_to_line(self)
	if d_d2l >= d.r then return nil, nil end
	-- 垂直直线
	local ip = d:foot_to_line(self)
	local d2 = math.sqrt(d.r*d.r - d_d2l*d_d2l)
	if math.abs(self.B) > math.abs(self.A) then
		local dx = d2 * math.abs(self.B) / math.sqrt(self.A*self.A+self.B*self.B)
		local x1, x2 = ip.x - dx, ip.x + dx
		return self:get_pt_with_x(x1), self:get_pt_with_x(x2)
	else
		local dy = d2 * math.abs(self.A) / math.sqrt(self.A*self.A+self.B*self.B)
		local y1, y2 = ip.y - dy, ip.y + dy
		return self:get_pt_with_y(y1), self:get_pt_with_y(y2)
	end
end

-- 获取夹角
function Geometry.Line:inter_angle_with_line( l )
	local a1 = Geometry.get_angle(self.B, -self.A)
	local a2 = Geometry.get_angle(l.B, -l.A)
	local ia = math.abs(a1 - a2)
	if ia > math.pi then ia = ia - math.pi end
	if ia > math.pi / 2 then ia = math.pi - ia end
	return ia
end

-------------------------------------------------------------------- 
-- Ray (Line) 射线
-------------------------------------------------------------------- 

-- point/ccp/ccsprite, angle
-- point/ccp/ccsprite, point/ccp/ccsprite
Geometry.Ray = class("Ray", function ( ... )
	local an
	local p, p2 = ...
	if p.__cname ~= "Point" then p = Geometry.Point.new(p) end
	if type(p2) == "number" then
		an = p2
	else
		if p2.__cname ~= "Point" then p2 = Geometry.Point.new(p2) end
		an = p:get_angle(p2)
	end
	an = Geometry.normalize_angle(an)
	local a, b = 100*math.sin(an), -100*math.cos(an)
	local r = Geometry.Line.new(p, a, b)
	r._line_funcs = {inter_pt_with_dot = r.inter_pt_with_dot,
				inter_pt_with_line = r.inter_pt_with_line}
	r.p = p
	r.an = an
	return r
end)

-- 判断直线上的点p是否在射线上，或者任意点是否在射线方向上
function Geometry.Ray:check_pt_inner( p )
	local strict = (p.x - self.p.x) * math.cos(self.an) + (p.y - self.p.y) * math.sin(self.an) >= 0
	local d = self.p:dis_to_point(p)
	local loose = d < 0.4
	return strict or loose
end

-- ray和dot的交点
function Geometry.Ray:inter_pt_with_dot( d )
	local p1, p2 = self._line_funcs.inter_pt_with_dot(self, d)
	local p = nil
	local mind = 0
	if p1 and self:check_pt_inner(p1) then
		p = p1
		mind = self.p:dis_to_point(p1)
	end
	if p2 and self:check_pt_inner(p2) then
		if self.p:dis_to_point(p2) < mind then
			p = p2
		end
	end
	return p
end

-- ray和line的交点
function Geometry.Ray:inter_pt_with_line( l )
	local p = self._line_funcs.inter_pt_with_line(self, l)
	local p_an = self.p:get_angle(p)
	if p and math.abs(p_an - self.an) < math.pi/2 then
		return p
	end
	return nil
end

-- ray和ray的夹角 0~pi
function Geometry.Ray:inter_angle_with_ray( r )
	local an = math.abs(self.an - r.an)
	if an > math.pi then 
		return math.pi*2 - an
	else
		return an
	end
end

-- ray被line反射
function Geometry.Ray:get_reflect_by_line( l )
	local ip = self:inter_pt_with_line(l)
	if not ip then return nil end
	local sp = self.p:symmetric_to_line(l)
	if not sp then return nil end
	local r = Geometry.Ray.new(sp, ip)
	r.p = ip
	return r
end

-- 获取截断点
function Geometry.Ray:get_point( len )
	local dx = len * math.cos(self.an)
	local dy = len * math.sin(self.an)
	local p2 = Geometry.Point.new(self.p.x+dx, self.p.y+dy)
	return p2
end

-- 截取一段segment
function Geometry.Ray:get_segment( l1, l2 )
	if l2 == nil then
		local p = self:get_point(l1)
		return Geometry.Segment.new(self.p, p)
	else
		if l1 >= l2 then return nil end
		local p1 = self:get_point(l1)
		local p2 = self:get_point(l2)
		return Geometry.Segment.new(p1, p2)
	end
end

-------------------------------------------------------------------- 
-- Segment (Ray) 线段
-------------------------------------------------------------------- 

-- point/sprite, point.sprite
Geometry.Segment = class("Segment", function ( p1, p2 )
	if p1.__cname ~= "Point" then p1 = Geometry.Point.new(p1) end
	if p2.__cname ~= "Point" then p2 = Geometry.Point.new(p2) end
	local seg = Geometry.Ray.new(p1, p2)
	seg.p1 = p1
	seg.p2 = p2
	return seg
end)

function Geometry.Segment:length(  )
	return self.p1:dis_to_point(self.p2)
end

-- segment和dot是否相交
function Geometry.Segment:check_inter_dot( d )
	local pa, pb = self._line_funcs.inter_pt_with_dot(self, d)
	if pa and self:check_pt_inner(pa) then
		return true
	end 
	if pb and self:check_pt_inner(pb) then
		return true
	end 
	return false
end

-- 判断直线上的点是否在线段上
function Geometry.Segment:check_pt_inner( p )
	return (p.x - self.p1.x) * (p.x - self.p2.x) <= 1e-8 and (p.y - self.p1.y) * (p.y - self.p2.y) <= 1e-8
end

-- 判断点p关于直线的垂足是否在线段上
function Geometry.Segment:check_pt_foot( p )
	local foot = p:foot_to_line(self)
	return self:check_pt_inner(foot)
end



