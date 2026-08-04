// worker.js
let intervalId = null;

self.onmessage = function (e) {
	const { action, intervalMs } = e.data;

	if (action === "start") {
		if (intervalId) clearInterval(intervalId);

		intervalId = setInterval(() => {
			// Just notify the main thread — no fetch here
			self.postMessage({ status: "tick", time: Date.now() });
		}, intervalMs || 60000);

		self.postMessage({ status: "started" });
	}

	if (action === "stop") {
		clearInterval(intervalId);
		intervalId = null;
		self.postMessage({ status: "stopped" });
	}
};