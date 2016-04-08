# Felix2Go
Felix2Go is a fully automated Debian Linux Installer which can be used to 
create a Debian based custom distribution.  

How to:
There are two bash scripts app-build.sh and iso-build.sh.  The app-build.sh
is used to build the so called apps which contains configuration files and 
script as a single self extracting file. The iso-build.sh is used to generate
 a iso which includes all the apps that are created using app-build.sh. 

The following sections will guide about the usage
Creating apps:
In the project there is an folder named 'app' and all the individual apps
should be created there. Each app needs to have its own directory.

Lets take the version-app as an example. The content of example look like this
$cd version-app
$tree
.
├── postinstall.sh
└── src
    └── etc
        └── felix_version

The file felix_version contains the version number of the project. The entire content 
under the folder src needs to be copied to the / folder in order to get the version
available in your distribution like this.

$cat /etc/felix_version
1.0

This is accomplished using postinstall.sh. The content of example look like this 
$cat postinstall.sh
#!/bin/bash

cd src
cp -a * /

This simple app is an example of how to create apps. For more details see other apps.
At the end to create all the apps in the 'apps' folder,run the app-build.sh script.
$./app-build.sh 
Generating Apps
Compressing...  conf-app
Compressing...  framework-app
Compressing...  version-app

This will compress and create self extracting app and copy them to the 'output' folder.

Adding package
If you want your CD to install some packages automatically to create your distro. 
-> Then open the file iso/felix-preseed.cfg.
-> Search for the line "d-i pkgsel/include". 
-> Insert your favourite debian package name at the end of the line
-> Save and exit

Generating iso
Login as root and run the iso-build.sh, the script will generate an iso file in the output folder
#./iso-build.sh
