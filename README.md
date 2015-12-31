# Electricity Meter Reader
It's my contribution to community to close the year of 2015.
The project is about electricity meter reader using Espruino board and framework. View the meter reading anywhere via iOS app.

This project contains two parts: 
* Espruino code. Only JavaScript code is uploaded, as I assume you'll use Espruino Web IDE
* Xcode project for iOS app. Code in Objective-C.


##Usage
In `espruino` folder, there's a `code.js` file.

Edit these parts:
* `<YOUR_SSID_NAME>	`: WiFi access point SSID to use
* `<YOUR_SSID_PASS>`: WiFi access point password
* `<YOUR_MQTT_SERVER>`: MQTT server to use. For testing, you can use Hive-MQ broker: `broker.hivemq.com`

In `ios` folder, also adjust the value for MQTT Server. Drill down and look at `ViewController` file, and change `MQTT_SERVER` constant value.

Enjoy! Happy New Year 2016.
