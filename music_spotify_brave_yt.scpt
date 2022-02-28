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

on getYtLabel()
	set ytStatusAndTitle to getYtStatusAndTitle()
	set ytTitle to ytStatusAndTitle's second item
	try
		if length of ytTitle > 50 then
			return (text 1 thru 50 of ytTitle) & "..."
		else
			return text 1 thru -11 of ytTitle
		end if
	end try
	return ""
end getYtLabel

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
	return {" ▷ | " & getSpotifyLabel(), "spotify"}
end if

set ytIsPlaying to isYtPlaying()
if ytIsPlaying then
	return {" ▷ | " & getYtLabel(), "youtube"}
end if

if application "Spotify" is running then
	set spotifyLabel to getSpotifyLabel()
	if spotifyLabel's contents is not "" and windowTitle is not "Brave Browser" or not ytTabIsOpen then
		return {" II ⎮ " & spotifyLabel, "spotify"}
	end if
end if

if ytTabIsOpen then
	return {" II ⎮ " & getYtLabel(), "youtube"}
end if

return {" ", "spotify"}