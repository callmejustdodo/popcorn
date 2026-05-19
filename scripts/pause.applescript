-- Finds the first supported video tab (YouTube, TikTok, Instagram) in the
-- given browser and pauses playback.
-- Usage: osascript pause.applescript "Google Chrome"

on run argv
	if (count of argv) < 1 then
		set browserName to "Google Chrome"
	else
		set browserName to item 1 of argv
	end if

	tell application "System Events"
		if not (exists process browserName) then return
	end tell

	if browserName is "Safari" then
		pauseInSafari()
	else
		pauseInChromium(browserName)
	end if
end run

on isSupportedUrl(u)
	if u contains "youtube.com" then return true
	if u contains "tiktok.com" then return true
	if u contains "instagram.com" then return true
	return false
end isSupportedUrl

on pauseInChromium(browserName)
	-- Pick the largest *visible* video element — Shorts / Reels / TikTok feeds
	-- keep hidden 0x0 video slots that querySelector('video') would otherwise grab.
	set jsSnippet to "(function(){var v=Array.from(document.querySelectorAll('video')).filter(function(x){var r=x.getBoundingClientRect();return r.width>0&&r.height>0;}).sort(function(a,b){var ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();return rb.width*rb.height-ra.width*ra.height;})[0]||document.querySelector('video');if(v&&!v.paused){v.pause();}return v?v.paused:false;})();"
	using terms from application "Google Chrome"
		tell application browserName
			try
				set windowCount to count of windows
				repeat with i from 1 to windowCount
					set tabCount to count of tabs of window i
					repeat with j from 1 to tabCount
						try
							set tabURL to URL of tab j of window i
							if my isSupportedUrl(tabURL) then
								tell tab j of window i to execute javascript jsSnippet
								return
							end if
						end try
					end repeat
				end repeat
			end try
		end tell
	end using terms from
end pauseInChromium

on pauseInSafari()
	set jsSnippet to "(function(){var v=Array.from(document.querySelectorAll('video')).filter(function(x){var r=x.getBoundingClientRect();return r.width>0&&r.height>0;}).sort(function(a,b){var ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();return rb.width*rb.height-ra.width*ra.height;})[0]||document.querySelector('video');if(v&&!v.paused){v.pause();}return v?v.paused:false;})();"
	tell application "Safari"
		try
			repeat with w in windows
				repeat with t in tabs of w
					try
						if my isSupportedUrl(URL of t) then
							do JavaScript jsSnippet in t
							return
						end if
					end try
				end repeat
			end repeat
		end try
	end tell
end pauseInSafari
