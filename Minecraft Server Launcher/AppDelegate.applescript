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
    
    on splitText(theText, theDelimiter)
        set AppleScript's text item delimiters to theDelimiter
        set theTextItems to every text item of theText
        set AppleScript's text item delimiters to ""
        return theTextItems
    end splitText
    on applicationWillFinishLaunching_(aNotification)
        try
            do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server'"
            do shell script "rm -rf $HOME/'Library/Application Support/Minecraft Server'"
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
usage: Minecraft Server Launcher [-launch servername]
To launch a server from the command line, use '" & item 1 of args as text & "' -launch servername"
quit
                else
                if item 2 of args as text is "-launch"
                    set cpCount to 0
                    set repeatIndex to 0
                    set classPath to ""
                        set theName to item 3 of args
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
                set theWindow's isVisible to true
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
        set theName to text returned of (display dialog "Server name" default answer "Untitled Server" with title "New Server")
        try
            set allInst to do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'"
        on error
            set allInst to ""
        end try
        if allInst contains theName then
            display alert "Already exists"
            error number -128
        end if
        do shell script "touch $HOME/'Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
        try
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
            do shell script "mkdir $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'"
            do shell script "echo 'eula=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/eula.txt"
            set theApppath to the POSIX path of (do shell script "echo '" & (path to current application as text) & "'")
            do shell script "cp '" & theApppath & "Contents/Resources/MCServer.png' $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "'/icon.png"
            do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'"
        on error
            error number -128
        end try
        
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

    end launchinst_
    on editinst_(sender)
        set cpCount to 0
        set repeatIndex to 0
        set classPath to ""
        set allInstalledVersion to paragraphs of (do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'")
        try
            set theName to item 1 of (choose from list allInstalledVersion with title "Servers" with prompt "Choose a server")
        on error
            error number -128
        end try
        set theEditChoice to item 1 of (choose from list {"Open server folder", "Open server.properties", "Change version", "UIElement", "Rename server", "Change icon", "No GUI", "Delete server"} with title "Edit Server" with prompt "What do you want to edit?")
        if theEditChoice is "Open server folder" then
            do shell script "open -R $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'"
        else
            if theEditChoice is "Delete server" then
                display dialog "Are you sure you want to delete this server?"
                do shell script "rm -rf $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "'
                rm $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt'"
            else
            if theEditChoice is "Rename server" then
                set theNewName to text returned of (display dialog "Server name" default answer theName with title "Rename Server")
                try
                    set allInst to do shell script "ls $HOME'/Library/Application Support/Minecraft Server/installations'"
                on error
                    set allInst to ""
                end try
                if allInst contains theNewName then
                    display alert "Already exists"
                    error number -128
                end if
                do shell script "mv $HOME'/Library/Application Support/Minecraft Server/installations/" & theName & "' $HOME'/Library/Application Support/Minecraft Server/installations/" & thenewName & "'"
                do shell script "mv $HOME'/Library/Application Support/Minecraft Server/info/" & theName & ".txt' $HOME'/Library/Application Support/Minecraft Server/info/" & thenewName & ".txt'"
                else
                if theEditChoice is "Change icon" then
                    do shell script "cp '" & (the POSIX path of (choose file with prompt "Choose icon" of type "public.image")) & "' $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/icon.png'"
                else
                if theEditChoice is "UIElement" then
                    set theUIElem to display dialog "Do you want the server to be a UIElement? if it is, then it will not appear on the dock." buttons {"Yes", "No"}
                    if button returned of theUIElem is "Yes" then
                        do shell script "echo '-Dapple.awt.UIElement=true' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'"
                        else
                        do shell script "echo '' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/uielement'"
                        end if
                else
                if theEditChoice is "No GUI" then
                    set nogui to display dialog "Do you want the server open in Terminal without a GUI?" buttons {"Yes", "No"}
                    if button returned of nogui is "Yes" then
                        do shell script "touch $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
                        else
                        do shell script "rm $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/nogui'"
                        end if
                else
                if theEditChoice is "Open server.properties" then
                    try
                        set theProperties to (do shell script "cat $HOME/'Library/Application Support/Minecraft Server/installations/" & theName & "/server.properties'")
                        set theSerEdit's isVisible to true
                        set theSerEdit's title to "Editing server.properties for " & theName
                        theSerText's setString:theProperties
                        set theSerProName's stringValue to theName
                    on error
                        display alert "Error: server.properties not found." message "Try launching the server." as critical
                    end try
                else
                try
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
            end if
                end if
                end if
                end if
                end if
            end if
        end if
    end editinst_
    on saveserverproperties_(sender)
        set theServerProperties to theSerText's textStorage()
        set theSavedText to theServerProperties's |string|()
        set theS to theSavedText as text
        do shell script "echo '" & theS & "' > $HOME/'Library/Application Support/Minecraft Server/installations/" & theSerProName's stringValue & "/server.properties'"
        set theSerEdit's isVisible to false
    end saveserverproperties_
    on cancelproperties_(sender)
        set theSerEdit's isVisible to false
    end cancelproperties_
    on showabout_(sender)
        set theAbout's isVisible to true
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
    
end script
