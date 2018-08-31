application =
{

	content =
	{
		width = 768,
		height = 1024, 
		scale = "zoomEven",
		fps = 60,
		
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@3x"] = 3,
		},
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
