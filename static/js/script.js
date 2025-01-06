function fetchSignalData() {
    fetch('/api/signal')
        .then(response => response.json())
        .then(data => {
            if (data.error) {
                console.error(data.error);
                return;
            }
            const rsrqFill = document.getElementById('rsrq-fill');
            const rsrpFill = document.getElementById('rsrp-fill');
            const sinrFill = document.getElementById('sinr-fill');
            const rsrqValue = document.getElementById('rsrq-value');
            const rsrpValue = document.getElementById('rsrp-value');
            const sinrValue = document.getElementById('sinr-value');

            function updateProgress(element, percentage) {
                element.style.width = percentage + '%';
                if (percentage < 30) {
                    element.classList.remove('medium', 'high');
                    element.classList.add('low');
                } else if (percentage < 70) {
                    element.classList.remove('low', 'high');
                    element.classList.add('medium');
                } else {
                    element.classList.remove('low', 'medium');
                    element.classList.add('high');
                }
            }

            updateProgress(rsrqFill, data.rsrq.percentage);
            updateProgress(rsrpFill, data.rsrp.percentage);
            updateProgress(sinrFill, data.sinr.percentage);

            rsrqValue.textContent = `RSRQ: ${data.rsrq.value} dB (${data.rsrq.percentage.toFixed(2)}%)`;
            rsrpValue.textContent = `RSRP: ${data.rsrp.value} dBm (${data.rsrp.percentage.toFixed(2)}%)`;
            sinrValue.textContent = `SINR: ${data.sinr.value} dB (${data.sinr.percentage.toFixed(2)}%)`;
        })
        .catch(error => console.error('Error fetching signal data:', error));
}

document.getElementById('refresh-button').addEventListener('click', fetchSignalData);

// Initial fetch and periodic refresh
fetchSignalData();
setInterval(fetchSignalData, 5000);
