import serial
import time
import json
from flask import Flask, jsonify, render_template

app = Flask(__name__)

def read_signal_data(port):
    try:
        ser = serial.Serial(port, 115200, timeout=1)
        ser.write(b'AT+CESQ\r\n')
        time.sleep(1)  # 等待响应
        response = ser.read(ser.in_waiting).decode('utf-8').strip()
        ser.close()
        return response
    except Exception as e:
        print(f"Error reading from {port}: {e}")
        return None

def parse_signal_data(data):
    if not data:
        return None
    parts = data.split('\n')
    for part in parts:
        if part.startswith('+CESQ:'):
            values = part.split(':')[1].strip().split(',')
            if len(values) < 9:
                return None
            ss_rsrq, ss_rsrp, ss_sinr = int(values[6]), int(values[7]), int(values[8])
            rsrq = (ss_rsrq * 0.5) - 43
            rsrp = ss_rsrp - 156
            sinr = (ss_sinr * 0.5) - 23
            return rsrq, rsrp, sinr
    return None

def calculate_percentage(value, min_val, max_val):
    return (value - min_val) / (max_val - min_val) * 100

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/signal')
def get_signal():
    data = read_signal_data('/dev/ttyUSB3')
    if not data:
        return jsonify({'error': 'Failed to read signal data'}), 500
    signal_data = parse_signal_data(data)
    if signal_data is None:
        return jsonify({'error': 'Invalid signal data'}), 500
    rsrq, rsrp, sinr = signal_data
    rsrq_percentage = calculate_percentage(rsrq, -43, -1)
    rsrp_percentage = calculate_percentage(rsrp, -156, -29)
    sinr_percentage = calculate_percentage(sinr, -23, 40)
    return jsonify({
        'rsrq': {'value': rsrq, 'percentage': rsrq_percentage},
        'rsrp': {'value': rsrp, 'percentage': rsrp_percentage},
        'sinr': {'value': sinr, 'percentage': sinr_percentage}
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=500)
