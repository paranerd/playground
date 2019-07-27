#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <RCSwitch.h>

const char* ssid = "<SSID>";
const char* password = "<PASSWORD>";
const char* mqtt_server = "<MQTT_BROKER_IP>";

RCSwitch mySwitch = RCSwitch();
WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(100);
  // We start by connecting to a WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.print("WiFi connected (");
  Serial.print(WiFi.localIP());
  Serial.print(")");
  Serial.println("");
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);

    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("Connected");
      client.subscribe("/home/mqtt433/#");
    }
    else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      Serial.println("Trying again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Received message [");
  Serial.print(topic);
  Serial.print("] ");

  char msg[length + 1];

  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
    msg[i] = (char)payload[i];
  }

  Serial.println();

  msg[length] = '\0';
  Serial.println(msg);

  mySwitch.send(atoi(msg), 24);
}

void setup() {
  Serial.begin(9600);

  // Setup WiFi
  setup_wifi();

  // Setup MQTT
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Setup 433MHz Transmitter
  mySwitch.enableTransmit(0);
  mySwitch.setPulseLength(101);
  mySwitch.setProtocol(4);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }

  client.loop();
}
