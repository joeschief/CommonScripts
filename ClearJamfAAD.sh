#!/bin/sh


user=`/usr/bin/who | /usr/bin/awk '/console/{ print $1 }'`

killall 'JAMF'
echo "quit JAMF"
killall 'Company Portal' 
echo "quit Company Portal"
rm -fr "/Users/$user/Library/Application Support/com.microsoft.CompanyPortalMac.usercontext.info"
rm -fr "/Users/$user/Library/Application Support/com.jamfsoftware.selfservice.mac"
rm -fr "/Users/$user//Library/Saved Application State/com.jamfsoftware.selfservice.mac.savedState" 
rm -fr "/Users/$user/Library/Saved Application State/com.microsoft.CompanyPortalMac.savedState" 
rm -fr "/Users/$user/Library/Preferences/com.microsoft.CompanyPortalMac.plist"
rm -fr "/Users/$user/Library/Preferences/com.jamf.management.jamfAAD.plist" 
rm -fr "Users/$user/Library/Cookies/com.microsoft.CompanyPortalMac.binarycookies" 
rm -fr "/Users/$user/Library/Cookes/com.jamf.management.jamfAAD.binarycookies"

echo "Remove keychain password items"

security delete-generic-password -l 'com.jamf.management.jamfAAD'
security delete-generic-password -l 'com.microsoft.CompanyPortalMac'
security delete-generic-password -l 'com.microsoft.CompanyPortalMac.HockeySDK'
security delete-generic-password -l 'enterpriseregistration.windows.net'

#Replace-with-your-adfs-server-name-FQDN
security delete-generic-password -l 'https://<adfsFQDN>/idp/prp.wsf'
security delete-generic-password -l 'https://<adfsFQDN>/idp/prp.wsf/'
#Replace-with-your-adfs-server-name-FQDN

security delete-generic-password -l 'https://device.login.microsoftonline.com'
security delete-generic-password -l 'https://device.login.microsoftonline.com/' 
security delete-generic-password -l 'https://enterpriseregistration.windows.net' 
security delete-generic-password -l 'https://enterpriseregistration.windows.net/' 
security delete-generic-password -a 'com.microsoft.workplacejoin.thumbprint' 
security delete-generic-password -a 'com.microsoft.workplacejoin.registeredUserPrincipalName' 

removecert=$(security find-certificate -a -Z | grep -B 9 "MS-ORGANIZATION-ACCESS" | grep "SHA-1" | awk '{print $3}')
echo $removecert
security delete-identity -Z $removecert

#Clear JamfAAD Keychain Items
/Library/Application\ Support/JAMF/Jamf.app/Contents/MacOS/JamfAAD.app/Contents/MacOS/JamfAAD clean

answer=$( "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" \
-windowType utility \
-title "Intune" \
-description "Please re-register your Mac with Intune to enable access to OneDrive and other online tools by selecting Register and logging into the Company Portal Application.  When prompted for JamfAAD, enter your password and choose Always Allow." \
-icon /Applications/Company\ Portal.app/Contents/Resources/AppIcon.icns \
-button1 Register \
-defaultButton 1 )

echo $answer

if [[ $answer -eq 0 ]];then
	/usr/local/bin/jamf policy trigger -id <intune Self Service Policy>
else
	echo "Something has gone horribly wrong, definitely abort..."
fi

exit 0
