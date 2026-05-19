-- Finds the first YouTube tab in the given browser, switches focus to it,
-- and resumes playback. Pairs with pause.applescript which silently pauses
-- without disturbing focus.
--
-- Usage: osascript play.applescript "Google Chrome"
-- Supports Chromium-based browsers (Chrome, Arc, Brave, Edge) and Safari.

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
		playInSafari()
	else
		playInChromium(browserName)
	end if
end run

on playInChromium(browserName)
	-- Pick the largest *visible* video element (Shorts pages have hidden 0x0 video
	-- slots for ads / preloading; querySelector('video') would grab those).
	set jsSnippet to "(function(){var v=Array.from(document.querySelectorAll('video')).filter(function(x){var r=x.getBoundingClientRect();return r.width>0&&r.height>0;}).sort(function(a,b){var ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();return rb.width*rb.height-ra.width*ra.height;})[0]||document.querySelector('video');if(v&&v.paused){v.play().catch(function(){});}return v?!v.paused:false;})();"
	using terms from application "Google Chrome"
		tell application browserName
			try
				set windowCount to count of windows
				repeat with i from 1 to windowCount
					set tabCount to count of tabs of window i
					repeat with j from 1 to tabCount
						try
							set tabURL to URL of tab j of window i
							if tabURL contains "youtube.com" then
								tell tab j of window i to execute javascript jsSnippet
								set active tab index of window i to j
								set index of window i to 1
								activate
								return
							end if
						end try
					end repeat
				end repeat
			end try
		end tell
	end using terms from
end playInChromium

on playInSafari()
	set jsSnippet to "(function(){var v=Array.from(document.querySelectorAll('video')).filter(function(x){var r=x.getBoundingClientRect();return r.width>0&&r.height>0;}).sort(function(a,b){var ra=a.getBoundingClientRect(),rb=b.getBoundingClientRect();return rb.width*rb.height-ra.width*ra.height;})[0]||document.querySelector('video');if(v&&v.paused){v.play().catch(function(){});}return v?!v.paused:false;})();"
	tell application "Safari"
		try
			set windowCount to count of windows
			repeat with i from 1 to windowCount
				set tabCount to count of tabs of window i
				repeat with j from 1 to tabCount
					try
						if (URL of tab j of window i) contains "youtube.com" then
							do JavaScript jsSnippet in tab j of window i
							set current tab of window i to tab j of window i
							set index of window i to 1
							activate
							return
						end if
					end try
				end repeat
			end repeat
		end try
	end tell
end playInSafari
