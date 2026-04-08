(*
Local Kindle-oriented example for macOS Page Capture OCR.

This file is intentionally more concrete than the generic capture script.
Adjust the values for your Mac before running.

Compile with:
osacompile -o capture-kindle-local.scpt capture_kindle_local_example.applescript
*)

-- Example configuration
set pages to 400
set target to "Kindle"
set startPage to 1

-- Choose the arrow key that moves to the next page in your Kindle window.
-- 1 = send Left Arrow
-- 2 = send Right Arrow
set pageDirection to 2

set pauseTime to 1.0
set cropWidth to 0
set cropHeight to 0
set resizeWidth to 0
set filePrefix to "page"
set outputFolderPosix to "/Users/your-username/Desktop/KindlePageCapture"

«event sysoexec» "mkdir -p " & quoted form of outputFolderPosix

if pageDirection is 1 then
	set pageKeyCode to 123
else
	set pageKeyCode to 124
end if

if target is not "" then
	tell application target
		activate
	end tell
end if

delay pauseTime

repeat with currentPage from startPage to pages
	set paddedPage to my paddedIndex(currentPage)
	set outputPath to outputFolderPosix & "/" & filePrefix & paddedPage & ".png"

	«event sysoexec» "screencapture -x " & quoted form of outputPath

	if cropWidth is not 0 and cropHeight is not 0 then
		if resizeWidth is not 0 then
			«event sysoexec» "sips -c " & cropHeight & space & cropWidth & space & quoted form of outputPath & space & "--resampleWidth " & resizeWidth & space & "--out " & quoted form of outputPath
		else
			«event sysoexec» "sips -c " & cropHeight & space & cropWidth & space & quoted form of outputPath & space & "--out " & quoted form of outputPath
		end if
	end if

	tell application "System Events"
		key code pageKeyCode
	end tell

	delay pauseTime
end repeat

on paddedIndex(pageNumber)
	if pageNumber < 10 then
		return "000" & (pageNumber as string)
	else if pageNumber < 100 then
		return "00" & (pageNumber as string)
	else if pageNumber < 1000 then
		return "0" & (pageNumber as string)
	else
		return pageNumber as string
	end if
end paddedIndex
