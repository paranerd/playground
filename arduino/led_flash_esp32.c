#define LED 2 // If LED is GPIO2

void setup() {
	Serial.begin(115200);
	// put your setup code here, to run once:
	pinMode(LED, OUTPUT);
}

void loop() {
	// put your main code here, to run repeatedly:
	digitalWrite(LED, HIGH);
	delay(2000);
	digitalWrite(LED, LOW);
	delay(2000);

	Serial.println("Loop done");
}
