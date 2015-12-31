/**
 * Sensor part
 */

var isOn = false;
var lastOnTimestamp = 0;
var lastWattage = 0;

//Handle if meter's LED is ON. To determine frequency and the wattage.
function meterLedIsOn() {
  var theNow = Date.now();
  var ledPulsePeriode = (theNow - lastOnTimestamp)/1000;
  lastOnTimestamp = theNow;  
  
  console.log("ON! Freq: " + (1/(1.0*ledPulsePeriode)) + " Hz");  
  
  //1000 pulse = 1kWh => 1 pulse = 1 wh
  
  lastWattage = (3600/ledPulsePeriode);

  console.log("Watt: " + lastWattage);  
  console.log("=================================");  
}

//Polling the reading from light sensor. 
//Should be as frequent as possible as we don't know the frequency between 1 ON to another of meter's LED. 
var i = setInterval(function() {

  //Read ADC value from light sensor
  var v = analogRead(A5);
  //console.log(v);
  
  //0.1 value is by experiment, adjust it based on your setup. 
  //For photosensitive diode, lower the value, brigther the light detected
  if (v < 0.1) { 
    if (isOn === false) {
      isOn = true;
      console.log(v);
      
      meterLedIsOn();
    }
  }
  else {
    //console.log("OFF!");
    isOn = false;
  }
}, 1);

/**
 * Internet connectivity part
 */

// Constants
var SSID_NAME = "<YOUR_SSID_NAME>";
var SSID_PASS = "<YOUR_SSID_PASS>";

var MQTT_SERVER = "<YOUR_MQTT_SERVER>";
var MQTT_PORT = 1883;
var MQTT_TOPIC = "andriyadi/xxxxyyyy01/wattage";

var TELEMETRY_INTERVAL = 3000; //3 seconds

digitalWrite(B9,0); // disable on Pico Shim V2
digitalWrite(B9,1); // reenable on Pico Shim V2
Serial2.setup(115200, { rx: A3, tx : A2 });

var mqttconnected = false;

var mqtt = require("MQTT").create(MQTT_SERVER, {port: MQTT_PORT});

mqtt.on('connected', function() {
  console.log("Connected to MQTT");
  //mqtt.subscribe("test");
  mqttconnected = true;
});

mqtt.on('disconnected', function() {
  console.log("Disconnected from MQTT");
  //mqtt.subscribe("test");
  mqttconnected = false;
  
  setTimeout(function() {
    if (mqttconnected) return;
    
    console.log("Reconnect to MQTT in 5 seconds");
    mqtt.connect();
    
  }, 5000);
});


// For posting real date time, need to get current timestamp. Then save to Clock module to keep the time.
var myClock;

function prepareRealTimeClock(cb) {
  require("http").get("http://currentmillis.com/time/seconds-since-unix-epoch/", function(res) {
    res.on('data', function(data) {
      console.log("HTTP> "+data);
      
      try {
        var s = parseInt(data, 10);
        //console.log("Parsed second: " + s);
        
        if (isNaN(s) === false) {
          var Clock = require("clock").Clock;
          myClock = new Clock();
          myClock.setClock(s*1000);
          cb(null, true);
        }
        else {
          cb(ex, false);
        }
      }
      catch(ex) {
        cb(ex, false);
        return;
      }
    });
  });
}

var wifi = require("ESP8266WiFi_0v25").connect(Serial2, function(err) {
  //                ^^^^^^^^^^^^^^^^
  // Use ESP8266WiFi here (and 9600 baud) if you have an ESP8266 with firmware older than 0.25

  if (err) throw err;
  wifi.reset(function(err) {
    if (err) throw err;
    console.log("Connecting to WiFi...");
    wifi.connect(SSID_NAME, SSID_PASS, function(err) {
      if (err) throw err;
      console.log("WIFI Connected!");
      
      prepareRealTimeClock(function(err, result) {
        if (!err) {
          console.log(myClock.getDate().toString());    
        }
        
        mqtt.connect(); 
      });      
       
    });
  });
});

var submittedWattage = 0;
setInterval(function() {
  if(!mqttconnected) return;
  
  if (submittedWattage == lastWattage || lastWattage === 0) {
    // Telemetry data is not ready. Return
    return;
  }
  
  //var dt = myClock? myClock.getDate().toString(): new Date().toString();
  
  var dt = myClock? myClock.getDate().getTime(): Date.now();
  
  var payload = JSON.stringify({    
    wattage: lastWattage,
    timestamp: dt
  });
  
  mqtt.publish(MQTT_TOPIC, payload);
  
  submittedWattage = lastWattage;
  
}, TELEMETRY_INTERVAL);

