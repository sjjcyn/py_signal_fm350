#!/bin/bash

# 发送AT+CESQ命令并获取返回结果
response=$(sms_tool -D -d /dev/ttyUSB3 at 'AT+CESQ' | grep '+CESQ' | awk '{print $2}')

# 提取ss_rsrq, ss_rsrp, ss_sinr的值
IFS=',' read -ra values <<< "$response"
ss_rsrq=${values[6]}
ss_rsrp=${values[7]}
ss_sinr=${values[8]}

# 计算信号值
rsrq_value=$(echo "scale=1; ($ss_rsrq * 0.5) - 43" | bc)
rsrp_value=$(echo "scale=1; ($ss_rsrp * 1) - 156" | bc)
sinr_value=$(echo "scale=1; ($ss_sinr * 1) - 23" | bc)

# 计算信号百分比
rsrq_percentage=$(echo "scale=1; ($ss_rsrq / 126) * 100" | bc)
rsrp_percentage=$(echo "scale=1; ($ss_rsrp / 126) * 100" | bc)
sinr_percentage=$(echo "scale=1; ($ss_sinr / 126) * 100" | bc)

# 输出为JSON格式
echo '{
  "ss_rsrq": {
    "value": '"$rsrq_value"'dB,
    "percentage": '"$rsrq_percentage"'%
  },
  "ss_rsrp": {
    "value": '"$rsrp_value"'dBm,
    "percentage": '"$rsrp_percentage"'%
  },
  "ss_sinr": {
    "value": '"$sinr_value"'dB,
    "percentage": '"$sinr_percentage"'%
  }
}'