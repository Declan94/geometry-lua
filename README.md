Geometry
==============

Simple analytic geometry tools implemented by lua <br/>
using for cocos2d games

## Classes

### Inherit Relationships

	Geometry.Point
		|
	Geometry.Dot

	Geometry.Line
		|
	Geometry.Ray
		|
	Geometry.Segment

### Attributes and methods

* Geometry.Point
	* Attributes
		* x 	- number, the X coordinate
		* y	- number, the Y coordinate
	* Construction: Geometry.Point.new(...)
		* x(number), y(number)
		* (Geometry.Point object)
		* (CCSprite object)
		* (CCPoint object)
	* Methods
		* to_ccp() 	-  convert to cocos2d point (cocos2dx 2.x)
		* get_angle(p)	- get the angle of the line connecting the point and p(Geometry.Point) to the X axis
		* dis_to_line(l)	- get the distance to the line l(Geometry.Line)
		* dis_to_point(p)	- get the distance to the point p(Geometry.Point)
		* foot_to_line(l)	- get the foot point to the line l(Geometry.Line)
		* symmetric_to_line(l)	- get the symmetric point of the line l(Geometry.Line)

* Geometry.Dot (Geometry.Point)
	* Attributes
		* r	-	number, dot radius
	* Construction: Geometry.Dot.new(...)
		* x(number), y(number), r(number)
		* p(Geometry.Point object), r(number)
		* sp(CCSprite object), r(number)
		* p(CCPoint object), r(number)

* Geometry.Line
	* Attributes
		* A, B, C	-	line equation: Ax + By + C = 0
	* Construction: Geometry.Line.new(...)
		* a(number), b(number), c(number)
		* p1, p2	p1, p2 is object of Geometry.Point/CCSprite/CCPoint
		* p, a(number), b(number)
	* Methods:
		* get_pt_with_x(x)	- get the point on line with X coordinate
		* get_pt_with_y(y)	- get the point on line with Y coordinate
		* inter_pt_with_line(l)	- get the intersection point with the line l(Geometry.Line)
		* inter_pt_with_dot(d)	- get the intersection points (two points) with the dot d(Geometry.Dot)
		* inter_angle_with_line(l)	- get the intersection angle with the line l(Geometry.Line)

* Geometry.Ray (Geometry.Line)
	* Attributes
		* p	-	start point of the ray
		* an	-	the angle between the ray direction and the X axis (from 0 to 2pi)
	* Construction: Geometry.Ray.new(...)
		* p(point), p2(point)		point means Geometry.Point/CCSprite/CCPoint
		* p(point), an(number)
	* Methods:
		* inter_pt_with_dot(d)	- get the intersection point with the dot d(Geometry.Dot) <br/>
					- return the point which is nearer to the start point p when exists two intersection points
		* inter_pt_with_line(l)	- get the intersection angle with the line l(Geometry.Line)
		* inter_angle_with_ray(r)	- get the intersection angle with the ray r(Geometry.Ray) (from 0 to pi)
		* get_reflect_by_line(l)	- get the reflected ray by the line l(Geometry.Line)
		* get_point(len)	- get the point on the ray whose distance to the start point is len
		* get_segment(l1, l2)

* Geometry.Segment (Geometry.Ray)
	* Attributes
		* p1, p2	- terminal points
	* Construction: Geometry.Segment.new(p1, p2)
	* Methods:
		* length()	- get then length of the segment
		* check_inter_dot(d)	-	check whether intersect with the dot d(Geometry.Dot)
		* check_pt_inner(p)	-	check the point p which is on the line whether in the segment
		* check_pt_foot(p)	-	check the foot point of p whether in the segment
		
	

