# Bash Shell script to deploy Cisco Secure Client 5 to MacOS devices via Intune

Please reference this KBA for pictured instructions: [How to deploy Cisco Secure Client via Intune (MacOS)](https://support.umbrella.com/hc/en-us/articles/23372033235348-How-to-deploy-Cisco-Secure-Client-via-Intune-MacOS)

## Installation 

Download and save the file as a **.mobileconfig** from this GitHub repo.

## Usage

This is a step-by-step guide on how to deploy Cisco Secure Client to your macOS devices via Intune. It is done with the assumption that your macOS device is already Managed by Intune. If you need to MDM your macOS device, please follow Microsoft's documentation. 

**DISCLAIMER: This article is provided as-is as of 02-01-2024. Umbrella support does not guarantee these instructions will remain valid after this date and is subject to change based on updates from Microsoft Intune and Apple macOS.**

**Procedure:**
1. Download the Cisco Secure Client disk image (DMG) from your Umbrella dashboard, under Deployments --> Roaming Computers --> top right: Roaming Client --> Pre-Deployment Package --> macOS.
2. Follow our [documentation](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-enroll#enable-enrollment-in-microsoft-intune) to craft your disk image (DMG) until you've reached Step 5.
3. Eject the disk image you've just crafted. One way to verify the disk image has been crafted properly, is by double-clicking "csc-writeable.dmg" and verify **ACTransforms.xml**, **install_choices.xml**, and **OrgInfo.json** are still in its respective place. Place this disk image in a central location that your macOS devices can access such as but not limited to NAS or a shared folder.
4. Login to you Intune instance at [https://intune.microsoft.com](https://intune.microsoft.com) and navigate to **Apps --> macOS --> Add --> Select app type: macOS app (DMG)**. Upload your crafted disk image from Step 3 and give it a unique name.
5. Select your minimum OS requirement based on your company's compliance policies. On the Detection Rule page, configure the **App bundle ID (CFBundleIdentifier)** and **App version (CFBundleShortVersionString)** with the following values:

Ignore app version: | Yes
--------------------|-----
App bundle ID (CFBundleIdentifier): | com.cisco.anyconnect.gui
App version (CFBundleShortVersionString): | enter the version you're deploying (ex. 5.1.1.42)

6. In Assignments, select your desired user/device assignment and click Create. 

7. On the far left menu, browse to **Devices --> macOS --> Configuration profiles** and create the following policies to silently enable the required System Extensions in order for Cisco Secure Client with Umbrella module to run correctly without user interactions:

[Cisco Secure Client Changes Related to macOS 11 (And Later)](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-1/macos11-on-ac.html)

**Create --> New Policy --> Profile type: Settings catalog --> Name: ManagedLoginItems --> Add Settings -->** search for **Managed Login Items** --> select **Login > Service Management - Managed Login Items** --> expand the rules at the bottom and select **Comment, Rule Type, and Rule Value**. 

8. Close the right side panel and click + **Edit Instance** and enter the following values, removing the last row for "Team Identifiers":

Comment: | Cisco Secure Client
---------|-----
Rule Type: | Team Identifier
Rule Value: | DE8Y96K9QP

9. In Scopes and Assignments, select your desired user/device assignment and click Create. 
10. Navigate back to **Configuration profiles --> Create --> New Policy --> Profile type: Templates --> Extensions --> Create --> Name: SystemExtensions**. Expand System Extensions and enter the following values:

**Allowed system extensions**

Bundle identifier: | com.cisco.anyconnect.macos.acsockext
---|---
Team Identifier: | DE8Y96K9QP

**Allowed system extension types**

Team identifier: | DE8Y96K9QP
---|---
Allowed system extension types: | Network extensions

11. In Assignments, select your desired user/device assignment and click Create.
12. Navigate to [Cisco Secure Client Changes Related to macOS 11 (And Later)](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-1/macos11-on-ac.html) and copy the sample XML and save it as a **.mobileconfig** file. 
13. Navigate back to **Configuration profiles --> Create --> New Policy --> Profile type: Templates --> Custom --> Create --> **Name: **WebContentFilter** --> Custom Configuration profile name: **WebContentFilter** --> Deployment channel: **Device channel**. Upload the .mobileconfig file you saved from the previous step:
14. In Assignments, select your desired user/device assignment and click Create.
15. Download the bash shell script from this GitHub Repo. Modify ```Line 5``` and ```Line 8``` to the respective version you're deploying. On ```Line 9```, modify the file path to point to the central location where you shared the disk image (DMG) in Step 3. 
16. In Intune, on the far left menu, navigate to **Devices --> macOS --> Shell scripts --> Add**. Give it a unique name. Upload the bash shell script downloaded from the previous step and ensure the following values are configured:

Run script as signed-in user: | No
---|---
Hide script notification on devices: | Yes
Script frequency: | Every 15 minutes
Max number of times to retry if script fails: | 3 times

17. In Assignments, select your desired user/device assignment and click Create.
18. On the far left menu, navigate to **Devices --> macOS** and click on one of your macOS device(s) that is suppose receive the Cisco Secure Client deployment. In Overview, click **Sync** so your desired macOS device(s) can pick up the changes. You may track the progress by navigating to Device configuration on the same page and see if the extensions we've configured starting Step 7 has been pushed successfully. 

## NOTE: On the same page, under Managed Apps you may notice an error under Installation Status: Failed. You may safely disregard this error - the Cisco Secure Client should be successfully deployed to your macOS device(s) when it successfully checks in and sync with Intune. 


## Deploying the Cisco Umbrella Root Certificate:
***This step only applies to new deployments of Cisco Secure Client or devices that does not have the Cisco Umbrella Root Certificate deployed previously.*** If you're migrating over from the Umbrella Roaming Client or Cisco AnyConnect 4.10 client, and/or have deployed the Cisco Umbrella Root Certificate already in the past, you may skip this step. 

1. In your Umbrella dashboard, under **Deployments --> Configuration --> Root Certificate**, download the Cisco Umbrella Root Certificate. 
2. In Intune, on the far left menu, navigate to **Devices --> macOS --> Configuration profiles --> Create --> New Policy --> Profile type: Templates --> Trusted certificate --> Create**. 
3. Give it a unique name like "Cisco Umbrella Root Certificate". In Configuration settings, upload the root certificate downloaded from the previous step. 
4. In Assignments, select your desired user/device assignment and click Create.
5. Navigate back to the overview of your macOS devices and click Sync. Just like previously in Step 18, this allows the desired macOS device(s) to pick up the changes during the device's next check-in with Intune. 

 

## Verify:
You may verify Cisco Secure Client with Umbrella module is working by either browsing to [https://policy-debug.checkumbrella.com](https://policy-debug.checkumbrella.com) or by running the following command:

`dig txt debug.opendns.com`

Either output should contain unique and relevant information to your Umbrella organization such as your OrgID. 
