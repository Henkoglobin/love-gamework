local rectUtil = {}

function rectUtil.isInRect(rect, pointX, pointY)
	return pointX >= rect.x
		and pointY >= rect.y
		and pointX <= rect.x + rect.w
		and pointY <= rect.y + rect.h
end

return rectUtil
