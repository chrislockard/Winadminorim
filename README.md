#Winadminorim.ps1 - A Windows Admin Powershell Library

INSTALLATION:
 1. Save this file somewhere convenient, preferably without spaces in the path (e.g. C:\Users\Scripts\Winadminorim.ps1)
 2. Open a Powershell console
 3. Type "$profile" (without quotes) and note the location provided.  On this host,
the $profile variable returned this directory:
C:\Users\<username>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
 4. Type "notepad $profile" (without quotes)
 5. If on a Vista, 7, 2008 or later host, click "OK" at the warning message.  Notepad should come up with a blank 
file.  This is OK.  Type the following into this blank file:
 6. Save this file as whatever filename the $profile variable from step 3 returned.
Now, when you start a Powershell session, Winadminorim will be loaded by default.  
ANY CHANGES TO WINADMINORIM REQUIRE A NEW POWERSHELL SESSION TO BE STARTED!

#Load Winadminorim
   . C:\Users\Scripts\Winadminorim.ps1 #If this is where you placed the Winadminorim.ps1 file. 

NOTE THE PERIOD (.) at the start of the directory listing.  THIS IS IMPORTANT!
