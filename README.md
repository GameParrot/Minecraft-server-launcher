# Minecraft-server-launcher
Minecraft Server Launcher lets you have all your server(s) in one easy to use launcher on your Mac.
# Getting started:
To get started, just use the installer from the Releases and start the app. The first time you launch it, you will be asked if you agree to the Minecraft EULA (https://account.mojang.com/documents/minecraft_eula). To create your first server, use the "New Server" button.
# Launching your server:
Just use the Launch server button and choose your server.
# Editing your server:
Use the Edit Server button and choose your server. An editing window will show up. The UIElement option can be used to make the server appear as a window but not on the dock. The change icon option can be used to change the icon on the dock. The NO GUI option lets you make the server launch in Terminal without a GUI.
# Command line usage:
You can use the the terminal to launch a server using -launch server_name. Example: ```open -a 'Minecraft Server Launcher' --args -launch 'My Server'```
You can also edit a server using the command line with -edit. Example: ```open -a 'Minecraft Server Launcher' --args -edit 'My Server' changeVersion 1.17.1```
# How this works:
You need to have launched the version you plan on using for your server at least once in the vanilla launcher because it loads the server class file from the vanilla client JAR file. It also gets the required class path from the JSON file. Because you cannot launch the server from the client JAR file directly on versions older than 1.13, it only supports 1.13 and newer. You do not need to have Java installed because it uses the version bundled with Minecraft (you do need to launch Minecraft 1.18 or newer at least once for it to download the right version of Java).
# Building from source:
If you want to build this using Xcode, make sure to set the development team before building, or else it will fail.
# Screenshots:
Main screen in light mode:
![lightscreenshot1](https://user-images.githubusercontent.com/85067619/144342840-5adda6f7-f243-46db-a8f4-d1b31759bc3f.jpg)
![lightscreenshot2](https://user-images.githubusercontent.com/85067619/144342841-c8004c80-8b13-4d97-8879-86be944df6fb.jpg)

Main screen in dark mode:
![darkscreenshot1](https://user-images.githubusercontent.com/85067619/144342838-6825ed5f-16dd-4a4f-9936-2608b895190a.jpg)
![darkscreenshot2](https://user-images.githubusercontent.com/85067619/144342839-a0be79dd-ee3a-416c-902b-b81ce71ae8a5.jpg)

Server running:
![running](https://user-images.githubusercontent.com/85067619/131271655-ca55bc95-cbaa-4fa0-b2d1-a41301625ff0.jpg)
