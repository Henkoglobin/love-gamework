local config

config = {
	project = {
		name = "gamework"
	},
	profiles = {
		debug = {
			defines = { DEBUG = true, RELEASE = false }
		},
		release = {
			defines = { DEBUG = false, RELEASE = true }
		}
	},
	targets = {
		runLocal = {
			deploy = function()
				return os.execute(([[love %s.love]]):format(config.project.name))
			end,
		},
		android = {
			deploy = function()
				local command = ("adb push %s.love /sdcard/%s.love"):format(config.project.name, config.project.name)
				print(command)
				assert(os.execute(command))
				command = ([[adb shell am start -S -n "org.love2d.android/.GameActivity" -d "file:///sdcard/%s.love"]]):format(config.project.name)
				print(command)
				assert(os.execute(command))
				
			end
		}
	}
}

return config