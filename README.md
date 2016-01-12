Geometry
==============

# Simple analytic geometry tools implemented by lua
# using for cocos2d games

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
		* x 	-	number, the X coordinate
		* y		-	number, the Y coordinate
	* Methods
		* new(...)	- construction methods, params can be:
			* x, y
			* CCSprite object
			* CCPoint object
			* Geometry.Point object
		* to_ccp() 	- 	convert to cocos2d point (cocos2dx 2.x)
		* get_angle(p)	-	get the angle of the line connecting the point and p(Geometry.Point) to the X axis
		* dis_to_line(l)	-	get the distance to the line l(Geometry.Line)
		* dis_to_point(p)	-	get the distance to the point p(Geometry.Point)
		* foot_to_line(l)	-	get the foot point to the line l(Geometry.Line)
		* symmetric_to_line(l)	-	get the symmetric point of the line l(Geometry.Line)
	

