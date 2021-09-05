--
--  AppDelegate.applescript
--  Minecraft Server Launcher
--
--  Created by GameParrot on 8/24/21.
--  
--

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
    
    -- the splitText function is used for getting the classpath from the json file.
    on splitText(theText, theDelimiter)
        set AppleScript's text item delimiters to theDelimiter
        set theTextItems to every text item of theText
        set AppleScript's text item delimiters to ""
        return theTextItems
    end splitText
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
            set args to (current application's NSProcessInfo's processInfo()'s arguments())
            if item 2 of args as text is "-h" or item 2 of args as text is "--help"
                log "
usage: Minecraft Server Launcher [-launch servername] [-edit servername edit_id value]
To launch a server from the command line, use '" & item 1 of args as text & "' -launch servername
To edit a server from the command line, use -edit servername [UIElement <0> <1>] [NoGUI <0> <1>] [Delete] [changeVersion <version>]"
-- Shows the help message
quit
                else
                if item 2 of args as text is "-launch"
                    set cpCount to 0
                    set repeatIndex to 0
                    set classPath to ""
                        set theName to item 3 of args
                        -- Gets the main class, depending on the version
                    try
                        set theVersion to do shell script "cat $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
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
                        do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
                        set classPath to "-cp '\\''" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "'\\'' " & mainclass
                        
                        do shell script "echo '#!/bin/sh
                        cd $HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "'\\''
                        rm /tmp/serverlaunch
                                exec $HOME'\\''" & "/Library/Application Support/minecraft/runtime/java-runtime-alpha/mac-os/java-runtime-alpha/jre.bundle/Contents/Home/bin/java'\\'' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='\\''MC Server: " & theName & "'\\'' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png'\\'' " & classPath & " nogui' > /tmp/serverlaunch"
                                do shell script "chmod +x /tmp/serverlaunch
                                open /tmp/serverlaunch -F -b com.apple.Terminal"
                    on error
                        set classPath to "-cp '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "' " & mainclass
                        
                        do shell script "cd $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'
                                $HOME'" & "/Library/Application Support/minecraft/runtime/java-runtime-alpha/mac-os/java-runtime-alpha/jre.bundle/Contents/Home/bin/java' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='MC Server: " & theName & "' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png' " & classPath & " > /dev/null 2>&1 & "
                    end try
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
                log "Ignored Argument: " & item 2 of args as text
                set theWindow's isVisible to true
                end if
                end if
                end if
            on error
            set theWindow's isVisible to true
            end try
        end try
	end applicationWillFinishLaunching_
    
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
    on idisagree_(sender)
        quit
    end idisagree_
    on iagree_(sender)
        display alert "I have read and agree to the Minecraft EULA" buttons {"Cancel", "I agree"} cancel button "Cancel"
        set theEULAWindow's isVisible to false
        set theWindow's isVisible to true
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server'"
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/info'"
        do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/installations'"
    end iagree_
    on newinst_(sender)
        set cpCount to 0
        set repeatIndex to 0
        set classPath to ""
        set theName to text returned of (display dialog "Server name" default answer "Untitled Server" with title "New Server") -- Asks for the name
        try
            set allInst to do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'" -- Checks if a server with the specified name already exists
        on error
            set allInst to ""
        end try
        if allInst contains theName then
            display alert "Already exists"
            error number -128
        end if
        do shell script "touch $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'" -- Creates the version file
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
            do shell script "echo '" & theVersion & "' > $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
            do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'"
            do shell script "echo 'eula=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/eula.txt"
            set theApppath to the POSIX path of (do shell script "echo '" & (path to current application as text) & "'")
            do shell script "cp '" & theApppath & "Contents/Resources/MCServer.png' $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/icon.png"
            do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'"
        on error
            error number -128
        end try
        current application's NSLog("Server created")
        display alert "Created server"
    end newinst_
    on launchinst_(sender)
        set cpCount to 0
        set repeatIndex to 0
        set classPath to ""
        set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
        try
            set theName to item 1 of (choose from list allInstalledVersion with title "Servers" with prompt "Choose a server")
        on error
            error number -128
        end try
        -- Gets the main class
        try
            set theVersion to do shell script "cat $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
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
            do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
            set classPath to "-cp '\\''" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "'\\'' " & mainclass
            
            do shell script "echo '#!/bin/sh
            cd $HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "'\\''
            rm /tmp/serverlaunch
                    exec $HOME'\\''" & "/Library/Application Support/minecraft/runtime/java-runtime-alpha/mac-os/java-runtime-alpha/jre.bundle/Contents/Home/bin/java'\\'' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='\\''MC Server: " & theName & "'\\'' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'\\''Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png'\\'' " & classPath & " nogui' > /tmp/serverlaunch"
                    do shell script "chmod +x /tmp/serverlaunch
                    open /tmp/serverlaunch -F -b com.apple.Terminal"
        on error
            set classPath to "-cp '" & (do shell script "echo \"$HOME/Library/Application Support/minecraft/libraries/\"") & classPath & "' " & mainclass
            
            do shell script "cd $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'
                    $HOME'" & "/Library/Application Support/minecraft/runtime/java-runtime-alpha/mac-os/java-runtime-alpha/jre.bundle/Contents/Home/bin/java' " & (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'") & " -Xdock:name='MC Server: " & theName & "' -Dapple.awt.application.appearance=system -Xdock:icon=$HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png' " & classPath & " > /dev/null 2>&1 & "
        end try
        current application's NSLog("Server launched")
    end launchinst_
    on editinst_(sender)
        set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
        try
            set theName to item 1 of (choose from list allInstalledVersion with title "Servers" with prompt "Choose a server")
        on error
            error number -128
        end try
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
    end editinst_
    on saveserverproperties_(sender)
        set theServerProperties to theSerText's textStorage() -- Gets the text from the server.properties editor
        set theSavedText to theServerProperties's |string|() -- Converts the text from the server.properties editor to a string
        set theS to theSavedText as text
        do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theSerProName's stringValue & "/server.properties'" -- Deletes the existing server.properties
        repeat with ii in (paragraphs of theS)
        do shell script "echo '" & ii & "' >> $HOME/'Library/Application Support/Minecraft Server/installations/" & theSerProName's stringValue & "/server.properties'" -- Creates the new server.properties
        end repeat
        current application's NSLog("Saved server.properties")
        set theSerEdit's isVisible to false -- Hides the server.properties window
    end saveserverproperties_
    on cancelproperties_(sender)
        set theSerEdit's isVisible to false -- Hides the server.properties window
    end cancelproperties_
    on showabout_(sender)
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
            set allInst to do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'" -- Gets all the servers
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
            theSerText's setString:theProperties -- Sets the text displayed in the server.properties editor too the server.properties file contents
            set theSerProName's stringValue to theName
        on error
            display alert "Error: server.properties not found." message "Try launching the server." as critical
        end try
    end openproperties_
    on openfolder_(sender)
        set theName to theServerEditing's stringValue
        do shell script "open -R $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'" -- Opens the server folder in Finder
    end openfolder_
    on changeversion_(sender)
        set theName to theServerEditing's stringValue
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
            set theVersion to item 1 of (choose from list theSupportedVersions with title "Minecraft versions" with prompt "Choose Minecraft verson. The version will not work if it is modded or if it has never been ran in the launcher.")
            do shell script "echo '" & theVersion & "' > $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        end try
    end changeversion_
    on deleteserver_(sender)
        set theName to theServerEditing's stringValue
        display dialog "Are you sure you want to delete this server? This action cannot be undone." -- Asks if you want to delete the server
        do shell script "rm -rf $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'
        rm $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        set theEditWindow's isVisible to false
    end deleteserver_
    on edithelp_(sender)
        set theEditHelpWindow's isVisible to true
    end edithelp_
end script
