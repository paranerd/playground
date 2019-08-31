/*
HTML:
<button class="box" data-oid="wohnzimmerlampe" data-type="switch">
	<i class="icon far fa-lightbulb" data-oid="wohnzimmerlampe" data-type="bool" data-class-true="icon fas fa-lightbulb yellow outline" data-class-false="icon far fa-lightbulb"></i>
	<span class="label">Wohnzimmer</span>
</button>

NodeJS:
io.on('connection', function(socket) {
	let client = mqtt.connect('mqtt://192.168.178.79:1883');

	client.on('connect', function () {
		console.log("MQTT connected");
		client.subscribe('#', function(err) {
			console.log("Error subscribing");
		});

		socket.on('mqtt', function(msg) {
			client.publish(msg.topic, msg.message);
		});

		client.on('message', function (topic, message) {
			socket.emit('mqtt', {topic: topic, message: message.toString()});
		});
	});

	client.on('error', function() {
		console.log("An error occurred");
	});

	socket.on('disconnect', function() {
		console.log('Client disconnected');
	});
});
*/

let devices = [
	{
		alias: 'wohnzimmerlampe',
		pub: 'hmip.0.devices.3014F711A00008570991052C.channels.1.on',
		sub: 'hmip.0.devices.3014F711A00008570991052C.channels.1.on',
		valueTrue: true,
		valueFalse: false,
		currentValue: null,
	},
	{
		alias: 'esszimmerlampe',
		pub: 'mqtt.0.shellies.shelly1-BA25F9.relay.0.command',
		sub: 'mqtt.0.shellies.shelly1-BA25F9.relay.0',
		valueTrue: 'on',
		valueFalse: 'off',
		currentValue: null,
	},
	{
		alias: 'haustuer',
		pub: 'hmip.0.devices.3014F711A000085709A3EEAC.channels.1.on',
		sub: 'hmip.0.devices.3014F711A000085709A3EEAC.channels.1.on'
	}
];

servConn.namespace   = 'mobile.0';
servConn._useStorage = false;

var states = [];
servConn.init({
	name:          'mobile.0',
	connLink:      '192.168.178.79:8084',
	socketSession: '' // optional - used by authentication
}, {
	onConnChange: function (isConnected) {
		if (isConnected) {
			console.log('Connected');

			init();
		}
		else {
			console.log('Disconnected');
		}
	},
	onRefresh: function () {
		window.location.reload();
	},
	onUpdate: function (id, state) {
		setTimeout(function () {
			var device = id_to_device(id);
			if (device) {
				setReaderState(device, state.val);
			}

			states[id] = state;
		}, 0);
	},
	onError: function (err) {
		window.alert(_('Cannot execute %s for %s, because of insufficient permissions', err.command, err.arg), _('Insufficient permissions'), 'alert', 600);
	}
});

function alias_to_device(device_needle) {
	for (device of devices) {
		if (device.alias == device_needle) {
			return device;
		}
	}
}

function id_to_device(id) {
	for (device of devices) {
		if (device.sub == id) {
			return device;
		}
	}
}

function init() {
	// Init switches
	$("[data-oid][data-type='switch']").each(function() {
		let device = alias_to_device($(this).data('oid'));
		$(this).on('click', function() {
			servConn.getStates([device.pub], (err, res) => {
				let newVal = (res[device.pub].val == device.valueTrue) ? device.valueFalse : device.valueTrue;
				servConn.setState(device.pub, newVal);
			});
		});
	});

	let oids = [];
	$("[data-oid][data-type='bool']").each(function() {
		let device = alias_to_device($(this).data('oid'));
		oids.push(device.sub);
	});

	// Init state readers
	servConn.getStates(oids, (err, states) => {
		$.each(states, function(oid, state) {
			setReaderState(id_to_device(oid), state.val);
		});
	});
}

function setReaderState(device, val) {
	let elem = $("[data-oid='" + device.alias + "'][data-type='bool']");

	device.currentValue = val;

	if (val == device.valueTrue && $(elem).data('class-true')) {
		$(elem).removeClass().addClass($(elem).data('class-true'));
	}
	else if (val == device.valueFalse && $(elem).data('class-false')) {
		$(elem).removeClass().addClass($(elem).data('class-false'));
	}
}
