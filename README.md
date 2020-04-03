# ESP8266DeautherGUI
This is a simple software to use the deauther from a pc through USB serial communication.


# How does it work?
This little software has some interesting functions to manage the deauther in the best way.
First of all, we can see in the GUI that there is a send field and a send button, so it's possible to override
all the DeautherGUI commands and buttons by writing your own custom commands in the field and hitting enter.

Moreover, it's possible to scan stations and scrolling them after scan is complete, choosing the targets by pressing 
the button <select/deselect> and then, starting the attack or stopping it by pressing < attack> or < stop> buttons.
 
The GUI also implements an alias managing function. There is a field under the < lag injecting> button to insert
an alias for a specific station. After clicking on < save> button, the alias is saved on the device and it will be used 
instead of the ID (that might change) in the future to attack a station. Since the aliases are saved on the device, it's possible
use it as a "pen drive" to transfer aliases data by different computers. The < delete> button is used to delete 
an alias (from the device memory).
 
The software will try to connect to the first available COM Port at startup. If there is another serial device connected, the GUI probably will connect to it if it's not busy and has a COM index higher than the NodeMCU one. If a device is busy, the software will skit to that one with a lower index and so on, until it finds an available one. 
If no available devices are found, the window remains grey.
 
# Important notes:
*This software uses the ControlP5 library and the Processing environment, so unless you are using the pre-compiled version
(Windows only) you need to install them.

*Java 8+ required

*Please, don't spam button clicks. Every time a button is pressed, the GUI Software sends a command via serial port, and the NodeMCU has to respond. This normally takes about one second, so wait a moment before pressing another button, anti-spam-clicks feature has not yet been implemented.

*This GUI (as the name say) exploits the Deauther function of the NodeMCU deauther firmware only, so is not possible to use beacon and probe functions.

*The software is limited to attack stations, the AP feature will be probably implemented in the future.

*DeautherGUI software is obviously free, no profit and open source, so only free stuff was used to create it.

*for every other reference regarding the board itself, please click this link: https://github.com/spacehuhn/esp8266_deauther/wiki

# Android version:
I'd like to add an Android-DeautherGUI APK to this repository so it's possible to control the board with an OTG cable and USB Serial Android libraries. I'm looking for someone who has some Android-coding experience and a NodeMCU board for testing that can collaborate with me on GitHub to make Android version.
