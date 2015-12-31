# Electricity Meter Reader
It's my contribution to community to close the year of 2015.
The project is about electricity meter reader using Espruino board and framework. View the meter reading anywhere via iOS app.

The story behind this project is [this deck](http://www.slideshare.net/andri_yadi/mobile-cloud-iot-case-study). I use this project as a demo for my talk in Bandung Developer Day #2 about Mobile + Cloud + IoT case study.

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


##Setup
To deploy this scenario, you need:
* Espruino Pico. Original board may work, but I don't have it for trying
* WiFi module. You can use this [WiFi shim](https://www.tindie.com/products/gfwilliams/espruino-pico-esp8266-wifi-shim/), or build your own like I did. The wiring and details are [here](http://www.espruino.com/ESP8266). In that link you get the instruction on how to setup the ESP8266 firmware.
* Light sensor. I use photosensitive diode light sensor. You can use LDR-based light sensor

Here's the setup photo. 

![Setup](https://raw.githubusercontent.com/andriyadi/Espruino-ElectricityMeterReader/master/Setup.jpg)

I admit that my wiring is wrong in that photo. 
The correct wiring: 
* AO of light sensor <—> A5 of Espruino Pico
* VCC of light sensor <—> 3.3v of Espruino Pico
* GND of light sensor <—> GND of Espruino Pico


##How It Looks
###Espruino app
![Espruino Web IDE](https://raw.githubusercontent.com/andriyadi/Espruino-ElectricityMeterReader/master/Capture-EspruinoWebIDE.png)

###iOS app
![iOS app](https://raw.githubusercontent.com/andriyadi/Espruino-ElectricityMeterReader/master/Capture-iOSApp.png)

Custom IoT/hardware for your startup? Contact DycodeX (office at dycode dot com)

That's it for now, enjoy! Happy New Year 2016.

 
