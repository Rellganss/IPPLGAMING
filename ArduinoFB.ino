#include <Arduino.h>
#if defined(ESP32)
  #include <WiFi.h>
#elif defined(ESP8266)
  #include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include <DHT.h>

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert your network credentials
#define WIFI_SSID "Kos Nawra"
#define WIFI_PASSWORD "101010ioioioNAwrA"

// Insert Firebase project API Key
#define API_KEY "AIzaSyCqkcY3yQUz77BH7oAilr1hskvZsld6rDw"

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL "https://mark-i-inferno-default-rtdb.firebaseio.com" 

#define DHTPIN 2          // Pin data sensor DHT22 terhubung ke pin GPIO2 (D2)
#define DHTTYPE DHT22     // Tipe sensor DHT22
#define FLAME_SENSOR_PIN 4  // Connect the flame sensor to digital pin 5
#define MQ2_SENSOR_PIN 5    // Connect the MQ-2 gas sensor to digital pin 6

DHT dht(DHTPIN, DHTTYPE);

//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

void setup(){
  Serial.begin(115200);
  dht.begin();
  pinMode(FLAME_SENSOR_PIN, INPUT);
  pinMode(MQ2_SENSOR_PIN, INPUT);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop(){
  float dhtHumidity = dht.readHumidity();
  float dhtTemperature = dht.readTemperature();
  int flameValue = digitalRead(FLAME_SENSOR_PIN);
  int mq2Value = digitalRead(MQ2_SENSOR_PIN);

  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)){
    sendDataPrevMillis = millis();
    // Write an Int number on the database path test/int
    if (!isnan(dhtHumidity) && !isnan(dhtTemperature)) {
    // Write DHT22 data to Firebase
      if (Firebase.RTDB.setFloat(&fbdo, "dht/kelembapan", dhtHumidity)) {
        Serial.println("DHT22 Humidity data sent to Firebase");
      } else {
        Serial.println("Failed to send DHT22 Humidity data to Firebase");
        Serial.println("REASON: " + fbdo.errorReason());
      }

      if (Firebase.RTDB.setFloat(&fbdo, "dht/suhu", dhtTemperature)) {
        Serial.println("DHT22 Temperature data sent to Firebase");
      } else {
        Serial.println("Failed to send DHT22 Temperature data to Firebase");
        Serial.println("REASON: " + fbdo.errorReason());
      }
    } else {
      Serial.println("Failed to read from DHT22 sensor");
    }

    if (Firebase.RTDB.setInt(&fbdo, "flame/api", flameValue)) {
      Serial.println("Flame sensor data sent to Firebase");
    } else {
      Serial.println("Failed to send Flame sensor data to Firebase");
      Serial.println("REASON: " + fbdo.errorReason());
    }

    if (Firebase.RTDB.setInt(&fbdo, "mq2/asap", mq2Value)) {
      Serial.println("MQ-2 sensor data sent to Firebase");
    } else {
      Serial.println("Failed to send MQ-2 sensor data to Firebase");
      Serial.println("REASON: " + fbdo.errorReason());
    }
  }
}