# Bash Shell script to deploy Cisco Secure Client 5 to MacOS devices via Intune

[How to deploy Cisco Secure Client via Intune (MacOS)](https://support.umbrella.com/hc/en-us/articles/23372033235348-How-to-deploy-Cisco-Secure-Client-via-Intune-MacOS)

## Installation 

Download and save the file as a **.mobileconfig**

Modify ```Line 5``` and ```Line 8``` to the respective Cisco Secure Client version you're deploying. On ```Line 9```, modify the file path to point to the central location where you shared the disk image (DMG) in Step 3 of the knowledge base article linked above.

## Usage

The entirety of this script is based on the instructions in the knowledge base article mentioned above, with the assumption you have reached Step 15.

In Intune, on the far left menu, navigate to Devices --> macOS --> Shell scripts --> Add. Give it a unique name. Upload the Bash Shell script downloaded (.mobileconfig) and ensure the following values are configured:

Run script as signed-in user: **No**

Hide script notification on devices: **Yes**

Script frequency: **Every 15 minutes**

Max number of times to retry if script fails: **3 times**

**Provided as-is 02/01/2024.**
