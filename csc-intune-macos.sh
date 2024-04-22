#!/bin/zsh

disk_image='csc-writeable.dmg'
folder='/Library/Intune'
# Change "5.1.1.42" to reflect the version being deployed
package_version='Cisco Secure Client 5.1.1.42'
package_installer='Cisco Secure Client.pkg'
AppFILE='/Applications/Cisco/Cisco Secure Client.app'
# Change "5.1.1.42" to reflect the version being deployed
version='5.1.1.42'
# Change 'ENTER_YOUR_URL_HERE' to the centrally shared location/URL where your csc-writeable.dmg is
URLPathForDownloadFile='ENTER_YOUR_URL_HERE'

# Checks if there is an existing instance of standalone Umbrella Roaming Client, AnyConnect, and/or old version of Cisco Secure Client installed

if [ -f "$AppFILE/Contents/Info.plist" ]; then
    appBundleVersion=$(/usr/libexec/plistbuddy -c "Print CFBundleVersion" "${AppFILE}/Contents/Info.plist")

    if [ "$appBundleVersion" = "$version" ]; then
        echo "Same version found: $appBundleVersion. No installation needed."
    elif [ "$appBundleVersion" < "$version" ]; then
        echo "Old version found: $appBundleVersion. Will install: $version."
        Install_Client='true'
    else
        echo "Newer version found: $appBundleVersion. No installation needed."
    fi
else
    echo "No file found, proceeding with installation."
    # returns Install_Client='true' to proceed with the next function
    Install_Client='true'
fi

# Runs when no existing instance of standalone Umbrella Roaming Client, AnyConnect, and/or old version of Cisco Secure CLient found, 

if [ "$Install_Client" = 'true' ]; then
    # delete any existing csc-writeable.dmg in /Library/Intune to ensure clean starting state
    rm -f $folder/"$disk_image"
    cd $folder
    # extract the DMG from centrally shared URL path
    curl $URLPathForDownloadFile/$disk_image --output "$disk_image"
    # attach the DMG with -nobrowse to NOT show the mounted volume (DMG) in Finder and -quiet to surpress any terminal output
    hdiutil attach $disk_image -nobrowse -quiet
    cd "/Volumes/$package_version"
    # Run the installer against install_choices.xml with the accepted parameters to install selected modules
    installer -pkg "$package_installer" -applyChoiceChangesXML install_choices.xml -target /
    sleep 5
    # detach the DMG and remove the csc-writeable.dmg from end device
    hdiutil detach "/Volumes/$package_version" -force -quiet
    rm -f $folder/"$disk_image"
fi
