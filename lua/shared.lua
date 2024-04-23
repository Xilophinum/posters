Config = {}
Config.OxInv = false

GetCoordsInFrontOfCam = function(...)   
	local unpack = table.unpack   
	local coords,direction = GetGameplayCamCoord(), RotationToDirection()   
	local inTable  = {...}   
	local retTable = {}    
	if (#inTable == 0) or (inTable[1] < 0.000001) then
		inTable[1] = 0.000001
	end    
	for k,distance in pairs(inTable) do     
		if (type(distance) == "number") then       
			if (distance == 0) then         
				retTable[k] = coords       
			else         
				retTable[k] = vector3(coords.x + (distance * direction.x), coords.y + (distance * direction.y), coords.z + (distance * direction.z))  
			end     
		end   
	end   
	return unpack(retTable)
end

RotationToDirection = function(rot)
	rot = rot or GetGameplayCamRot(2)
	local rotZ = rot.z  * ( 3.141593 / 180.0 )
	local rotX = rot.x  * ( 3.141593 / 180.0 )
	local c = math.cos(rotX)
	local multXY = math.abs(c)   
	local res = vector3((math.sin(rotZ) * -1) * multXY, math.cos(rotZ) * multXY, math.sin(rotX)) 
	return res 
end

function DrawSelectedArea(PointA, PointB, minZ, maxZ, r, g, b, a)
	DrawPoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a)
	DrawPoly(PointB.x, PointB.y, minZ, PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, r, g, b, a)
end

function DrawImageOnArea(PointA, PointB, minZ, maxZ, r, g, b, a, texture, dict)
	DrawSpritePoly(PointB.x, PointB.y, minZ, PointB.x, PointB.y, maxZ, PointA.x, PointA.y, maxZ, r, g, b, a, texture, dict, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0)
	DrawSpritePoly(PointA.x, PointA.y, maxZ, PointA.x, PointA.y, minZ, PointB.x, PointB.y, minZ, r, g, b, a, texture, dict, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0)
end
