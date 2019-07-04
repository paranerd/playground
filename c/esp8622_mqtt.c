#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// Define NodeMCU D3 pin to as temperature data pin of DHT11
#define LED_POWER D4
#define LED_CONNECTED D0

// Update these with values suitable for your network.
const char* ssid = "SSID";
const char* password = "PASSWORD";
const char* mqtt_server = "192.168.178.79";

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

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

randomSeed(micros());
	Serial.println("");
	Serial.println("WiFi connected");
	Serial.println("IP address: ");
	Serial.println(WiFi.localIP());
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
			Serial.println("connected");
		}
		else {
			Serial.print("failed, rc=");
			Serial.print(client.state());
			Serial.println("Try again in 5 seconds");
			// Wait 5 seconds before retrying
			delay(5000);
		}
	}
}

void setup() {
	Serial.begin(115200);
	pinMode(LED_POWER, OUTPUT);
	pinMode(LED_CONNECTED, OUTPUT);

	// Show that ESP is powered
	digitalWrite(LED_POWER, HIGH);

	// Setup WiFi
	setup_wifi();

	// Show that WiFi is connected
	digitalWrite(LED_CONNECTED, HIGH);

	// Connect to MQTT broker
	client.setServer(mqtt_server, 1883);
}

void loop() {
	if (!client.connected()) {
		reconnect();
	}

	client.loop();
	long now = millis();

	// Send update every 10s
	if (now - lastMsg > 10000) {
		lastMsg = now;
		value = value + 1;

		String msg = "";
		char msgArr[25];
		msg = value;
		msg.toCharArray(msgArr, 25);

		// Publish value in topic /testing
		client.publish("testing", msgArr);
	}
}
