--
--  AppDelegate.applescript
--  Minecraft Server Launcher
--
--  Created by GameParrot on 8/24/21.
--  
--
global statusBar
global statusBarItem
script AppDelegate
    use framework "Foundation"
    use framework "AppKit"
    use framework "WebKit"
    use scripting additions
	property parent : class "NSObject"
	-- IBOutlets
	property theWindow : missing value
    property theEULAWindow : missing value
    property eulaWeb : missing value
    property theAbout : missing value
    property theSerEdit : missing value
    property theSerText : missing value
    property theSerProName : missing value
    property theUIElementButton : missing value
    property theEditWindow : missing value
    property theServerEditing : missing value
    property theNoGUIButton : missing value
    property theRenameField : missing value
    property theEditHelpWindow : missing value
    property theBG : missing value
    property theUpdateCheckBox : missing value
    property thePreferenceWindow : missing value
    property theMenuCheckBox : missing value
    property theLegacyWindow : missing value
    property theAboutVersion : missing value
    property theServerChooser : missing value
    property newButton : missing value
    property editButton : missing value
    property launchButton : missing value
    property theLaunchButton : missing value
    property theEditButton : missing value
    property theCancelButton : missing value
    property theNameText : missing value
    property theNewVersion : missing value
    property theNewCancel : missing value
    property theNewCreate : missing value
    property theVersionChooser : missing value
    property theJVMArg : missing value
    property theServerArg : missing value
    property theColorCodeWindow : missing value
    -- the splitText function is used for getting the classpath from the json file.
    on splitText(theText, theDelimiter)
        set AppleScript's text item delimiters to theDelimiter
        set theTextItems to every text item of theText
        set AppleScript's text item delimiters to ""
        return theTextItems
    end splitText
    on findAndReplaceInText(theText, theSearchString, theReplacementString) -- the findAndReplaceInText function is used for fixing MC-2215
        set AppleScript's text item delimiters to theSearchString
        set theTextItems to every text item of theText
        set AppleScript's text item delimiters to theReplacementString
        set theText to theTextItems as string
        set AppleScript's text item delimiters to ""
        return theText
    end findAndReplaceInText
    on getPositionOfItemInList(theItem, theList)
        repeat with a from 1 to count of theList
            if item a of theList is theItem then return a
        end repeat
        return 0
    end getPositionOfItemInList
    on hideButtons() -- Hides the main UI
        newButton's setHidden:true
        editButton's setHidden:true
        launchButton's setHidden:true
    end hideButtons
    on showButtons() -- Shows the main UI
        newButton's setHidden:false
        editButton's setHidden:false
        launchButton's setHidden:false
    end showButtons
    on createThumbnailImage(imgPath) -- this function creates a 16x16 image for a server icon
        set sourceImg to current application's NSImage's alloc()'s initWithContentsOfFile:imgPath
        set scaledImg to current application's NSImage's alloc()'s initWithSize:(current application's NSMakeSize(16, 16))
        scaledImg's lockFocus()
        set sourceImg's size to (current application's NSMakeSize(16, 16))
        set (current application's NSGraphicsContext's currentContext())'s imageInterpolation to 3
        sourceImg's drawInRect:(current application's NSMakeRect(0.0, 0.0, 16, 16))
        scaledImg's unlockFocus()
        set theResult to (current application's NSBitmapImageRep's imageRepWithData:(scaledImg's TIFFRepresentation))'s representationUsingType:(current application's NSPNGFileType) |properties|:(current application's NSDictionary's dictionary())
        return current application's NSImage's alloc's initWithData:theResult
    end createThumbnailImage
    on NSLog(theLogText)
        current application's NoTimestampLog's notimestamp_(theLogText)
    end NSLog
    on updatemenu()
        set theMenuEnabled to do shell script "defaults read ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar" -- Reads the settings file to check if Add to Menu Bar is enabled
        if theMenuEnabled is "1"
            set theHomePath to do shell script "echo \"$HOME\""
            set newMenu to current application's NSMenu's alloc()'s initWithTitle:"Custom"
            newMenu's removeAllItems()
            set someListInstances to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
            
            repeat with i from 1 to number of items in someListInstances
                set theItemImage to theHomePath & "/Library/Application Support/Minecraft Server/installations/" & item i of someListInstances & "/icon.png"
                set this_item to item i of someListInstances
                set thisMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:this_item action:("launchMenu:") keyEquivalent:"")
                try
                    thisMenuItem's setImage:(createThumbnailImage(theItemImage))
                end try
                (newMenu's addItem:thisMenuItem)
                (thisMenuItem's setTarget:me)
            end repeat
            statusBarItem's setMenu:newMenu
        end if
    end updatemenu
    on checkforupdates_(sender)
        updatecheck(true)
    end checkforupdates_
    on updatecheck(showAlert)
        if (do shell script "curl -L 'https://github.com/GameParrot/Minecraft-server-launcher/raw/main/.update/currentversion'") is not equal to current application's version -- Checks to see if the update file does not match the current version
            applyupdates()
        else
            if showAlert then
                display alert "Up to date" message "You are running the latest version of Minecraft Server Launcher."
            end if
        end if
    end updatecheck
    on applyupdates()
        try
        display alert "Update available!" message "Release notes:
        " & (do shell script "curl -L 'https://github.com/GameParrot/Minecraft-server-launcher/raw/main/.update/releasenotes.txt'") buttons {"Cancel", "Update"} cancel button "Cancel" default button "Update"
        NSLog("Requesting admin privileges")
        do shell script "echo 'curl -L \"https://github.com/GameParrot/Minecraft-server-launcher/blob/main/.update/MCServerLaunch.zip?raw=true\" > /tmp/update.zip
        rm -rf \"/Applications/Minecraft Server Launcher.app\"
        unzip /tmp/update.zip -d /Applications
        rm /tmp/update.zip
        open \"/Applications/Minecraft Server Launcher.app\"' | zsh > /dev/null 2>&1 & " with administrator privileges
        NSLog("Updating")
        quit
        end try
    end applyupdates
    on launchMenu:sender
        launchserver(sender's title as text)
    end launchMenu:
    on loadRandomImage()
        if (random number from 1 to 2) is equal to 1 then
        set theBG's image to current application's NSImage's imageNamed:"image2"
        end if
    end loadRandomImage
    on createMenu()
        set statusBar to current application's NSStatusBar's systemStatusBar
        set statusBarItem to statusBar's statusItemWithLength:-1.0
        statusBarItem's setTitle:"Launch Server"
        statusBarItem's setImage:(current application's NSImage's imageNamed:"servermenuicon")
        updatemenu()
    end createMenu
    
    on applicationWillFinishLaunching_(aNotification)
        try
            -- Checks if it is the first launch
            do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server'"
            do shell script "rm -rf $HOME/'Library/Application Support/Minecraft Server'"
            -- Shows the EULA if it is the first launch
            set theEULAWindow's isVisible to true
            set theWindow's isVisible to false
            set theURLString to "https://account.mojang.com/documents/minecraft_eula"
            set theURL to current application's |NSURL|'s URLWithString:theURLString
            set theRequest to current application's NSURLRequest's requestWithURL:theURL
            eulaWeb's loadRequest:theRequest
            on error
            try
                do shell script "ls $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app'"
            on error
                do shell script "unzip '" & the POSIX path of (path to current application) & "Contents/Resources/MCServerApp.zip' -d $HOME'/Library/Application Support/Minecraft Server'"
                do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
                do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
            end try
            try
            set args to (current application's NSProcessInfo's processInfo()'s arguments())
                if item 2 of args as text is "-launch"
                        launchserver(item 3 of args as text) -- Launches the server
                        quit
                else
                if item 2 of args as text is "-edit"
                    set theName to item 3 of args as text
                    if item 4 of args as text is "UIElement" then
                        if item 5 of args as text is "1" then
                            do shell script "echo '-Dapple.awt.UIElement=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'" -- Creates the UIElement file
                            else
                            do shell script "echo '' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'" -- Empties the UIElement file
                            end if
                    end if
                    if item 4 of args as text is "NoGUI" then
                        if item 5 of args as text is "1" then
                            do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'" -- Creates the NO GUI file
                        else
                            do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'" -- Removes the NO GUI file
                        end if
                    end if
                    if item 4 of args as text is "Delete" then
                        do shell script "rm -rf $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'
                        rm $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
                    end if
                    if item 4 of args as text is "changeVersion" then
                        set theVersion to item 5 of args as text
                        do shell script "echo '" & theVersion & "' > $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'" -- Copies the new version to the text file it reads from
                    end if
                    quit
                else
                
                if (system version of (system info)) is less than 10.14 then
                    set theLegacyWindow's isVisible to true  -- Uses a window that supports older macOS versions if needed.
                else
                    set theWindow's isVisible to true
                end if
                end if
                end if
            on error
            if (system version of (system info)) is less than 10.14 then
                set theLegacyWindow's isVisible to true
            else
                set theWindow's isVisible to true
            end if
            end try
        end try
        loadRandomImage()
        try
            set theUpdateEnabled to do shell script "defaults read ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AutoUpdateCheck" -- Checks if auto update is enabled
        if theUpdateEnabled is "1"
            updatecheck(false)
        end if
        on error
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AutoUpdateCheck -bool false"
        end try
        try
            set theMenuEnabled to do shell script "defaults read ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar" -- Checks if Add to Menu Bar is enabled
            if theMenuEnabled is "1"
                try
                createMenu()
                end try
            end if
        on error
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar -bool true"
            try
            createMenu()
            end try
        end try
	end applicationWillFinishLaunching_
    on preference_(sender)
        set thePreferenceWindow's isVisible to true
        try
            set theUpdateEnabled to do shell script "defaults read ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AutoUpdateCheck" -- Checks if auto update is enabled
            if theUpdateEnabled is "1" then
                set theUpdateCheckBox's state to true
            else
            set theUpdateCheckBox's state to false
            end if
        on error
            set theUpdateCheckBox's state to false
        end try
        try
            set theMenuEnabled to do shell script "defaults read ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar"
            if theMenuEnabled is "1" then
                set theMenuCheckBox's state to true
            else
            set theMenuCheckBox's state to false
            end if
        on error
            set theMenuCheckBox's state to true
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar -bool true"
        end try
    end preference_
    on toggleautoupdate_(sender)
        if theUpdateCheckBox's state as boolean is true then
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AutoUpdateCheck -bool true"
        else
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AutoUpdateCheck -bool false"
        end if
    end toggleautoupdate_
    on togglemenubar_(sender)
        if theMenuCheckBox's state as boolean is true then
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar -bool true"
            createMenu()
        else
            do shell script "defaults write ~/Library/Preferences/com.gameparrot.Minecraft-server-launcher AddToMenuBar -bool false"
            statusBar's removeStatusItem_(statusBarItem)
        end if
    end toggleemenubar_
	on applicationShouldTerminate_(sender)
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    on idisagree_(sender)
        quit
    end idisagree_
    on iagree_(sender)
        display alert "I have read and agree to the Minecraft EULA" buttons {"Cancel", "I agree"} cancel button "Cancel"
        set theEULAWindow's isVisible to false
        if (system version of (system info)) is less than 10.14 then
            set theLegacyWindow's isVisible to true
        else
            set theWindow's isVisible to true
        end if
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server'"
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/info'"
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/installations'"
        do shell script "unzip '" & the POSIX path of (path to current application) & "Contents/Resources/MCServerApp.zip' -d $HOME'/Library/Application Support/Minecraft Server'"
        do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
        do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
    end iagree_
    on showCreateUI()
        theNewVersion's removeAllItems()
        theNameText's setHidden:false -- Shows the create UI
        theNewVersion's setHidden:false
        hideButtons()
        theNewCancel's setHidden:false
        theNewCreate's setHidden:false
        set theSupportedVersions to {}
        repeat with i in paragraphs of (do shell script "ls '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/versions\"") & "'")
            try
                set majorVersion to item 1 of splitText(item 2 of splitText(i, "."), "-")
                if (majorVersion as number) > 12 then
                    set end of theSupportedVersions to (i as text)
                end if
            on error
                try
                    set majorVersion to item 1 of splitText(i, "w")
                    if (majorVersion as number) > 17 then
                        set end of theSupportedVersions to (i as text)
                    end if
                end try
            end try
        end repeat
        set beginning of theSupportedVersions to "Latest snapshot"
        set beginning of theSupportedVersions to "Latest release"
        theNewVersion's addItemsWithTitles:theSupportedVersions -- Sets the version chooser list to all of the versions
    end showCreateUI
    on hideCreateUI()
        theNameText's setHidden:true
        theNewVersion's setHidden:true -- Hides the create UI
        showButtons()
        theNewCancel's setHidden:true
        theNewCreate's setHidden:true
    end hideCreateUI
    on cancelnew_(sender)
        hideCreateUI()
    end cancalnew_
    on createNew_(sender)
        createServer(theNameText's stringValue as string, theNewVersion's selectedItem's title as text)
        hideCreateUI()
    end createNew_
    on newinst_(sender)
        if not (system version of (system info)) is less than 10.14 then
            showCreateUI()
        else
            set cpCount to 0
            set repeatIndex to 0
            set classPath to ""
            set theName to text returned of (display dialog "Server name" default answer "Untitled Server" with title "New Server") -- Asks for the name
            try
                set allInst to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'") -- Checks if a server with the specified name already exists
            on error
                set allInst to ""
            end try
            if allInst contains theName then
                display alert "Already exists"
                error number -128
            end if
            try
                -- Lists all the versions
                set theSupportedVersions to {}
                repeat with i in paragraphs of (do shell script "ls '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/versions\"") & "'")
                    try
                        set majorVersion to item 2 of splitText(i, ".")
                        if (majorVersion as number) > 12 then
                            set end of theSupportedVersions to (i as text)
                        end if
                    on error
                        try
                            set majorVersion to item 1 of splitText(i, "w")
                            if (majorVersion as number) > 17 then
                                set end of theSupportedVersions to (i as text)
                            end if
                        end try
                    end try
                end repeat
                set theVersion to item 1 of (choose from list theSupportedVersions with title "Minecraft versions" with prompt "Choose Minecraft verson. The version will not work if it is modded or if it has never been ran in the launcher.") -- Asks the user for the version they want
                createServer(theName, theVersion)
            on error
                error number -128
            end try
        end if
    end newinst_
    on createServer(theName, theVersion)
        try
            set allInst to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'") -- Checks if a server with the specified name already exists
        on error
            set allInst to ""
        end try
        if allInst contains theName then
            display alert "Already exists"
            error number -128
        end if
        do shell script "touch $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        do shell script "echo '" & theVersion & "' > $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'"
        do shell script "echo 'eula=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/eula.txt"
        set theApppath to the POSIX path of (do shell script "echo '" & (path to current application as text) & "'")
        do shell script "cp '" & theApppath & "Contents/Resources/MCServer.png' $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/icon.png"
        do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'"
        NSLog("Server created: " & theName)
        display alert "Created server"
        updatemenu()
    end createServer
    on launchserver(theName)
        NSLog("Preparing to launch server: " & theName)
        set cpCount to 0
        set repeatIndex to 0
        set classPath to ""
        try
            set theVersion to do shell script "cat $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'" -- Gets the version to launch
            if theVersion is "Latest release" then
                try
                    set theVersion to item 1 of splitText(item 2 of splitText(do shell script "curl -L 'https://launchermeta.mojang.com/mc/game/version_manifest.json'", "\"release\": \""), "\"")
                on error
                    display alert "Could not get latest release" message "Check your internet connection and try again"

                end try
            end if
            if theVersion is "Latest snapshot" then
                try
                    set theVersion to item 1 of splitText(item 2 of splitText(do shell script "curl -L 'https://launchermeta.mojang.com/mc/game/version_manifest.json'", "\", \"snapshot\": \""), "\"")
                on error
                    display alert "Could not get latest snapshot" message "Check your internet connection and try again"
                end try
            end if
            set majorVersion to item 2 of splitText(theVersion, ".")
            if (majorVersion as number) < 16 then
                set mainclass to "net.minecraft.server.MinecraftServer"
            else
                set mainclass to "net.minecraft.server.Main"
            end if
        on error
            try
                set theVersion to do shell script "cat $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
                set majorVersion to item 1 of splitText(theVersion, "w")
                if (majorVersion as number) < 20 then
                    set mainclass to "net.minecraft.server.MinecraftServer"
                else
                    if (majorVersion as number is 20) and item 1 of splitText(item 2 of splitText(theVersion, "w"), "a") as number < 20 then
                        set mainclass to "net.minecraft.server.MinecraftServer"
                    else
                        set mainclass to "net.minecraft.server.Main"
                    end if
                end if
            on error
                set mainclass to "net.minecraft.server.Main"
            end try
        end try
        -- Gets the classpath from the json
        NSLog("Getting classpath from json")
        set theText to splitText((item 2 of splitText(do shell script "cat $HOME'/Library/Application Support/minecraft/versions/" & theVersion & "/" & theVersion & ".json'", "\"libraries\": ")), "{\"artifact\": {\"path\": \"")
        repeat with i in theText
            set repeatIndex to repeatIndex + 1
            if repeatIndex < (length of theText) then
                if cpCount is greater than 0 then
                    set classPath to classPath & item 1 of splitText(i, "\", \"") & ":" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"")
                else
                    set cpCount to cpCount + 1
                end if
            else
                set classPath to classPath & item 1 of splitText(i, "\", \"") & ":" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/versions/" & theVersion & "/" & theVersion & ".jar\"")
            end if
        end repeat
        -- Checks settings and launches the server
        try
            set jvmargs to do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/jvmargs'"
        on error
            set jvmargs to ""
        end try
        try
            set serverargs to do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/serverargs'"
        on error
            set serverargs to ""
        end try
        try
            do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
            set classPath to "-cp '\\''" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "'\\'' " & mainclass
            
            do shell script "echo '#!/bin/zsh
            cd $HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "'\\''
            rm /tmp/serverlaunch
                    exec $HOME'\\''" & "/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'\\'' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='\\''MC Server: " & theName & "'\\'' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png'\\'' " & jvmargs & " " & classPath & " nogui " & serverargs & "' > /tmp/serverlaunch"
                    do shell script "chmod +x /tmp/serverlaunch
                    open /tmp/serverlaunch -F -b com.apple.Terminal"
        on error
            set classPath to "-cp '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "' " & mainclass
            
            do shell script "cd $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'
                    '" & the POSIX Path of (path to current application as text) & "Contents/Resources/ServerLaunch.sh' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='MC Server: " & theName & "' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png' " & jvmargs & " " & classPath & " " & serverargs & "> /dev/null 2>&1 & "
        end try
        NSLog("Launched server: " & theName)
    end launchserver
    on addToPopUp(theList, isLaunch)
        hideButtons()
        if isLaunch then
            theLaunchButton's setHidden:false
        else
            theEditButton's setHidden:false
        end if
        theCancelButton's setHidden:false -- Shows the launch/edit UI
        theServerChooser's setHidden:false
        theServerChooser's removeAllItems()
        set theHomePath to do shell script "echo \"$HOME\""
        repeat with i in theList
            set theItemImage to theHomePath & "/Library/Application Support/Minecraft Server/installations/" & i & "/icon.png"
            theServerChooser's addItemWithTitle:i
            try
                theServerChooser's lastItem's setImage:createThumbnailImage(theItemImage)
            end try
        end repeat
    end addToPopUp
    on launchdirect_(sender)
        launchserver(theServerChooser's selectedItem's title as text)
        showButtons()
        theLaunchButton's setHidden:true
        theEditButton's setHidden:true -- Hides the launch/edit UI
        theCancelButton's setHidden:true
        theServerChooser's setHidden:true
    end launchdirect_
    on cancelserver_(sender)
        showButtons()
        theLaunchButton's setHidden:true
        theEditButton's setHidden:true -- Hides the launch/edit UI
        theCancelButton's setHidden:true
        theServerChooser's setHidden:true
    end cancelserver_
    on launchinst_(sender)
        if not (system version of (system info)) is less than 10.14 then
            set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
            addToPopUp(allInstalledVersion, true)
        else
            set cpCount to 0
            set repeatIndex to 0
            set classPath to ""
            set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
            try
                set theName to item 1 of (choose from list allInstalledVersion with title "Servers" with prompt "Choose a server")
            on error
                error number -128
            end try
            launchserver(theName) -- Launches the server
        end if
    end launchinst_
    on editinst_(sender)
        if not (system version of (system info)) is less than 10.14 then
            set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
            addToPopUp(allInstalledVersion, false)
        else
            set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
            try
                set theName to item 1 of (choose from list allInstalledVersion with title "Servers" with prompt "Choose a server")
            on error
                error number -128
            end try
            prepareEdit(theName)
        end if
    end editinst_
    on editdirect_(sender)
        prepareEdit(theServerChooser's selectedItem's title as text)
        showButtons()
        theLaunchButton's setHidden:true
        theEditButton's setHidden:true
        theCancelButton's setHidden:true -- Hides the launch/edit UI
        theServerChooser's setHidden:true
    end editdirect_
    on prepareEdit(theName)
        if (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") is "-Dapple.awt.UIElement=true" then
            set theUIElementButton's state to true
        else
            set theUIElementButton's state to false
        end if
        try
            do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
            set theNoGUIButton's state to true
        on error
            set theNoGUIButton's state to false
        end try
        set theEditWindow's isVisible to true
        set theEditWindow's title to "Editing " & theName
        set theServerEditing's stringValue to theName
        set theRenameField's stringValue to theName
        set theJVMArg's stringValue to ""
        set theServerArg's stringValue to ""
        try
            set theJVMArg's stringValue to do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/jvmargs'"
        end try
        try
            set theServerArg's stringValue to do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/serverargs'"
        end try
        try
            set theSupportedVersions to {} -- Gets all the supported versions
            repeat with i in paragraphs of (do shell script "ls '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/versions\"") & "'")
                try
                    set majorVersion to item 1 of splitText(item 2 of splitText(i, "."), "-")
                    if (majorVersion as number) > 12 then
                        set end of theSupportedVersions to (i as text)
                    end if
                on error
                    try
                        set majorVersion to item 1 of splitText(i, "w")
                        if (majorVersion as number) > 17 then
                            set end of theSupportedVersions to (i as text)
                        end if
                    end try
                end try
            end repeat
            set beginning of theSupportedVersions to "Latest snapshot"
            set beginning of theSupportedVersions to "Latest release"
            theVersionChooser's removeAllItems()
            theVersionChooser's addItemsWithTitles:theSupportedVersions
            set theCurrentVersion to do shell script "cat $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
             theVersionChooser's selectItemAtIndex:(getPositionOfItemInList(theCurrentVersion, theSupportedVersions) - 1)
        end try
    end prepareEdit
    on bringserverstofront_(sender)
        do shell script "open $HOME/'Library/Application Support/Minecraft Server/Minecraft Server.app'"
    end bringserverstofront_
    on saveserverproperties_(sender)
        set theServerProperties to theSerText's textStorage() -- Gets the text from the server.properties editor
        set theSavedText to theServerProperties's |string|() -- Converts the text from the server.properties editor to a string
        set theS to theSavedText as text
        do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theSerProName's stringValue & "/server.properties'" -- Deletes the existing server.properties
        repeat with ii in (paragraphs of theS)
        do shell script "echo '" & findAndReplaceInText(ii, "§", "\\u00A7") & "' >> $HOME/'Library/Application Support/Minecraft Server/installations/" & theSerProName's stringValue & "/server.properties'" -- Creates the new server.properties
        end repeat
        NSLog("Saved server.properties")
        set theSerEdit's isVisible to false -- Hides the server.properties window
    end saveserverproperties_
    on cancelproperties_(sender)
        set theSerEdit's isVisible to false -- Hides the server.properties window
    end cancelproperties_
    on showabout_(sender)
        set theAboutVersion's stringValue to "Version: " & current application's version
        set theAbout's isVisible to true -- Shows the about window
    end showabout_
    on githubpage_(sender)
        do shell script "open 'https://github.com/GameParrot/Minecraft-server-launcher'"
    end githubpage_
    on githubissuepage_(sender)
        do shell script "open 'https://github.com/GameParrot/Minecraft-server-launcher/issues'"
    end githubissuepage_
    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_
    on uielementtoggle_(sender)
        set theName to theServerEditing's stringValue
        if theUIElementButton's state as boolean is true then
            do shell script "echo '-Dapple.awt.UIElement=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'" -- Creates the UIElement file
            else
            do shell script "echo '' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'" -- Empties the UIElement file
            end if
    end uielementtoggle_
    on noguitoggle_(sender)
        set theName to theServerEditing's stringValue
        if theNoGUIButton's state as boolean is true then
            do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'" -- Creates the No GUI file
            else
            do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'" -- Removes the No GUI file
            end if
    end noguitoggle_
    on renameserver_(sender)
        set theName to theServerEditing's stringValue
        set theNewName to theRenameField's stringValue
        try
            set allInst to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'") -- Gets all the servers
        on error
            set allInst to ""
        end try
        if allInst contains theNewName then
            display alert "Already exists"
            set theRenameField's stringValue to theName
            error number -128
        end if
        do shell script "mv $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "' $HOME'/Library/Application Support/Minecraft Server/installations/" & theNewName & "'"
        do shell script "mv $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt' $HOME'/Library/Application Support/Minecraft Server/info/" & thenewName & ".txt'"
        set theServerEditing's stringValue to theNewName
        set theEditWindow's title to "Editing " & theNewName
        updatemenu()
    end renameserver_
    on changeicon_(sender)
        set theName to theServerEditing's stringValue
        do shell script "cp '" & (the POSIX path of (choose file with prompt "Choose icon" of type "public.image")) & "' $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png'" -- Copies the new icon
    end changeicon_
    on openproperties_(sender)
        set theName to theServerEditing's stringValue
        try
            set theProperties to (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/server.properties'") -- Reads the current server.properties
            set theSerEdit's isVisible to true -- Shows the server.properties editor window
            set theSerEdit's title to "Editing server.properties for " & theName  -- Sets the window title
            theSerText's setString:findAndReplaceInText(theProperties, "\\u00A7", "§") -- Sets the text displayed in the server.properties editor too the server.properties file contents
            set theSerProName's stringValue to theName
        on error
            display alert "Error: server.properties not found." message "Try launching the server." as critical
        end try
    end openproperties_
    on resetjvm_(sender)
        set theName to theServerEditing's stringValue
        set theJVMArg's stringValue to ""
        do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/jvmargs'"
    end resetjvm_
    on resetserverargs_(sender)
        set theName to theServerEditing's stringValue
        set theServerArg's stringValue to ""
        do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/serverargs'"
    end resetserverargs_
    on savejvm_(sender)
        set theName to theServerEditing's stringValue
        set theArgs to theJVMArg's stringValue as text
        do shell script "echo '" & theArgs & "' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/jvmargs'"
    end savejvm_
    on saveserverargs_(sender)
        set theName to theServerEditing's stringValue
        set theArgs to theServerArg's stringValue as text
        do shell script "echo '" & theArgs & "' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/serverargs'"
    end saveserverargs_
    on openfolder_(sender)
        set theName to theServerEditing's stringValue
        do shell script "open -R $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'" -- Opens the server folder in Finder
    end openfolder_
    on changeversion_(sender)
        set theName to theServerEditing's stringValue
        try
            set theVersion to theVersionChooser's selectedItem's title as text
            do shell script "echo '" & theVersion & "' > $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        end try
    end changeversion_
    on deleteserver_(sender)
        set theName to theServerEditing's stringValue
        display alert "Are you sure you want to delete this server? This action cannot be undone." buttons {"Cancel", "Delete"} cancel button "Cancel"  -- Asks if you want to delete the server
        do shell script "rm -rf $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'
        rm $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        set theEditWindow's isVisible to false
        updatemenu()
    end deleteserver_
    on edithelp_(sender)
        set theEditHelpWindow's isVisible to true
    end edithelp_
    on choosejavaexec_(sender)
        set theNewExec to the POSIX Path of (choose file with prompt "Choose new Java Executable:" of type "public.unix-executable")
        do shell script "rm $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
        do shell script "rm $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
        do shell script "ln -s '" & theNewExec & "' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
        do shell script "ln -s '" & theNewExec & "' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
        set theJavaExecWindow's isVisible to false
    end choosejavaexec_
    on resetjavaexec_(sender)
        do shell script "rm $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
        do shell script "rm $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
        do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/MacOS/Minecraft Server'"
        do shell script "ln -s '../../../../minecraft/runtime/java-runtime-beta/mac-os/java-runtime-beta/jre.bundle/Contents/Home/bin/java' $HOME'/Library/Application Support/Minecraft Server/Minecraft Server.app/Contents/Resources/Minecraft Server'"
        set theJavaExecWindow's isVisible to false
    end resetjavaexec_
    on resetproperties_(sender)
        set theName to theServerEditing's stringValue
        display alert "Are you sure you want to reset the server.properties?" buttons {"Cancel", "Reset"} cancel button "Cancel" -- Asks if you want to delete the server properties file
        do shell script "rm $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "/server.properties'"
    end resetproperties_
    on showcolorcodes_(sender)
        set theColorCodeWindow's isVisible to true
    end showcolorcodes_
end script
