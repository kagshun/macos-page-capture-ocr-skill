(*
Generic paginated-content capture script for macOS.

Edit the configuration block, then run from Script Editor
or compile with:

osacompile -o capture-pages.scpt capture_paginated_content.applescript
*)

-- Configuration
set pages to 400
set target to "Preview"
set startPage to 1
set pageDirection to 2 -- 1 = send Left Arrow, 2 = send Right Arrow
set pauseTime to 1.0
set cropWidth to 0
set cropHeight to 0
set resizeWidth to 0
set filePrefix to "page"
set outputFolderPosix to "/Users/your-username/Desktop/PageCapture"

-- Important:
-- pages is the inclusive end index for output filenames.
-- startPage is the starting index for output filenames.
-- The script does not jump the app to startPage for you.
-- pageDirection refers to the arrow key sent to advance to the next page.
-- It does not try to encode whether a book is "left-opening" or "right-opening".

my ensureFolderExists(outputFolderPosix)

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

	if currentPage is not pages then
		tell application "System Events"
			key code pageKeyCode
		end tell
		
		delay pauseTime
	end if
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

on ensureFolderExists(folderPath)
	«event sysoexec» "mkdir -p " & quoted form of folderPath
end ensureFolderExists
