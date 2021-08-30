# Minecraft-server-launcher
Minecraft Server Launcher lets you have all your server(s) in one easy to use launcher on your Mac.
# Getting started:
To get started, just use the installer from the Releases and start the app. The first time you launch it, you will be asked if you agree to the Minecraft EULA (https://account.mojang.com/documents/minecraft_eula). To create your first server, use the "New Server" button.
# Launching your server:
Just use the Launch server button and choose your server.
# Editing your server:
Use the Edit Server button and choose your server. You will be asked to choose what you want to edit. The UIElement option can be used to make the server appear as a window but not on the dock. The change icon option can be used to change the icon on the dock. The NO GUI option lets you make the server launch in Terminal without a GUI.
# Command line usage:
You can use the the terminal to launch a server using -launch server_name. Example: ```open -a 'Minecraft Server Launcher' --args -launch 'My Server'```
# How this works:
You need to have launched the version you plan on using for your server at least once in the vanilla launcher because it loads the server class file from the vanilla client JAR file. It also gets the required class path from the JSON file. Because you cannot launch the server from the client JAR file directly on versions older than 1.13, it only supports 1.13 and newer. You do not need to have Java installed because it uses the version buldled with Minecraft (you do need to launch 1.17 or newer once for it to download the right version of Java).
# Building from source:
If you want to build this using Xcode, make sure to set the development team before building, or else it will fail.
# Screenshots:
Main screen in light mode:
![lightscreenshot](https://user-images.githubusercontent.com/85067619/131271584-83945402-305f-4bbb-a07a-5c83141dc746.jpg)

Main screen in dark mode:
![darkscreenshot](https://user-images.githubusercontent.com/85067619/131271596-8f67568e-9834-4d02-9463-2b5480dda5c2.jpg)

Server running:
![running](https://user-images.githubusercontent.com/85067619/131271655-ca55bc95-cbaa-4fa0-b2d1-a41301625ff0.jpg)
