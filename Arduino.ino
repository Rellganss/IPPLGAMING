#include <DHT.h>

#define DHTPIN 2
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);
int flamePin = 3;  // Flame sensor pin
int gasPin = A0;   // MQ-2 sensor pin
int buzzerPin = 8; // Buzzer pin

void setup() {
  pinMode(flamePin, INPUT);
  pinMode(gasPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  dht.begin();
  Serial.begin(9600);
}

void loop() {
  float temperature = dht.readTemperature(); // Read temperature
  float humidity = dht.readHumidity();       // Read humidity

  int flameValue = digitalRead(flamePin);    // Read flame sensor
  int gasValue = analogRead(gasPin);         // Read gas sensor

  if (flameValue == LOW || gasValue > 200) {
    Serial.println("Kebakaran terdeteksi!");
    soundAlarm();
    // Lakukan tindakan darurat di sini, misalnya mengirim notifikasi, memadamkan api, dll.
  }

  // Print data
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.print("°C, Humidity: ");
  Serial.print(humidity);
  Serial.print("%, Flame: ");
  Serial.print(flameValue);
  Serial.print(", Gas: ");
  Serial.println(gasValue);

  

  delay(1000); // Delay between readings
}

void soundAlarm() {
  // Bunyikan alarm (buzzer)
  for (int i = 0; i < 5; i++) {
    digitalWrite(buzzerPin, HIGH);
    delay(500);
    digitalWrite(buzzerPin, LOW);
    delay(500);
  }
}