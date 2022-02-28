set windowTitle to ""
set ytTab to ""
set ytTabOpen to false
set ytTitle to ""
set ytStatus to ""

on getYtStatusAndTitle()
	tell application "Brave Browser"
		try
			set getWindowTitle to "document.title;"
			set getStatusScript to "document.querySelectorAll('div[class*=\"-mode\"]')[0].className.match(/(playing|paused|ended)-mode/)[1];"
			set ytTab to (front window's first tab whose URL contains "youtube.com/watch?v=")
			set ytStatus to execute ytTab javascript getStatusScript as text
			set ytTitle to execute ytTab javascript getWindowTitle as text
			return {ytStatus, ytTitle}
		on error
			return {"", ""}
		end try
	end tell
	return {"", ""}
end getYtStatusAndTitle

on isSpotifyPlaying()
	if application "Spotify" is running then
		tell application "Spotify"
			return player state is playing
		end tell
	end if
	return false
end isSpotifyPlaying

on isYtPlaying()
	set ytStatusAndTitle to getYtStatusAndTitle()
	set ytStatus to ytStatusAndTitle's first item
	set ytTitle to ytStatusAndTitle's second item
	return ytStatus is "playing"
end isYtPlaying

on getSpotifyLabel()
	try
		tell application "Spotify"
			return (get artist of current track) & " – " & (get name of current track)
		end tell
	end try
	return ""
end getSpotifyLabel

on handleYtAction()
	set braveWasInFocus to frontmost of application "Brave Browser"
	if application "Brave Browser" is not running or not braveWasInFocus then
		tell application "Brave Browser" to activate
	end if
	tell application "Brave Browser"
		set lastWindowIndex to active tab index of front window
		set ytTab to (front window's first tab whose URL contains "youtube.com/watch?v=")
		set ytTabOpen to (contents of ytTab is not "")
		if ytTabOpen then
			repeat with thisWindow in windows
				set cnt to 1
				repeat with thisTab in (tabs of thisWindow)
					if URL of thisTab contains "youtube.com/watch?v=" then
						set active tab index of front window to cnt
						exit repeat
					end if
					set cnt to cnt + 1
				end repeat
			end repeat
			tell application "System Events" to keystroke "k"
			if braveWasInFocus then
				set active tab index of front window to lastWindowIndex
			end if
			return
		end if
	end tell
end handleYtAction

tell application "System Events"
	set windowTitle to name of first application process whose frontmost is true
end tell

try
	if application "Brave Browser" is running then
		tell application "Brave Browser"
			set ytTab to (front window's first tab whose URL contains "youtube.com/watch?v=")
			set ytTabIsOpen to (contents of ytTab is not "")
		end tell
	end if
end try

set spotifyIsPlaying to isSpotifyPlaying()
if spotifyIsPlaying then
	tell application "Spotify" to playpause
	return
end if

set ytIsPlaying to isYtPlaying()
if ytIsPlaying then
	handleYtAction()
	return
end if

if application "Spotify" is running then
	set spotifyLabel to getSpotifyLabel()
	if spotifyLabel's contents is not "" and windowTitle is not "Brave Browser" or not ytTabIsOpen then
		tell application "Spotify" to playpause
		return
	end if
end if

if ytTabIsOpen then
	handleYtAction()
	return
end if

if application "Spotify" is running then
	tell application "Spotify" to activate
	tell application "Spotify" to reopen
	return
else
	tell application "Spotify" to activate
	return
end if