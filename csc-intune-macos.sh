#!/bin/zsh

disk_image='csc-writeable.dmg'
folder='/Library/Intune'
package_version='Cisco Secure Client 5.1.1.42'
package_installer='Cisco Secure Client.pkg'
AppFILE='/Applications/Cisco/Cisco Secure Client.app'
version='5.1.1.42'
URLPathForDownloadFile='ENTER_YOUR_URL_HERE'

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
    Install_Client='true'
fi

if [ "$Install_Client" = 'true' ]; then
    rm -f $folder/"$disk_image"
    cd $folder
    curl $URLPathForDownloadFile/$disk_image --output "$disk_image"
    hdiutil attach $disk_image -nobrowse -quiet
    cd "/Volumes/$package_version"
    installer -pkg "$package_installer" -applyChoiceChangesXML install_choices.xml -target /
    sleep 5
    hdiutil detach "/Volumes/$package_version" -force -quiet
    rm -f $folder/"$disk_image"
fi
