let wasmInstance;

createMyWasmModule().then(module => {
    wasmInstance = module;
    console.log("Wasm инициализирован");
});

function handleIncrement() {
    if (wasmInstance) {
        const result = wasmInstance._increment();
        document.getElementById('counterValue').innerText = result;
    } else {
	alert("Wasm hasn't download yet");
    }
}

