#!/bin/sh

# 创建 /etc/init.d/py_signal_fm350 文件并写入脚本内容
cat << 'EOF' > /etc/init.d/py_signal_fm350
#!/bin/sh /etc/rc.common

START=99
STOP=10
USE_PROCD=1

NAME="py_signal_fm350"
PROG="/usr/bin/python3"
SCRIPT="./app.py"  # 使用相对路径
WORKDIR="/root/py_signal_fm350"  # 指定工作目录

start_service() {
    procd_open_instance
    procd_set_param command /bin/sh -c "cd $WORKDIR && $PROG $SCRIPT"
    procd_set_param stdout 1  # 输出日志到系统日志
    procd_set_param stderr 1
    procd_set_param respawn  # 自动重启
    procd_close_instance
}

stop_service() {
    echo "Stopping $NAME"
}
EOF

# 赋予执行权限
chmod +x /etc/init.d/py_signal_fm350

# 加入开机启动
/etc/init.d/py_signal_fm350 enable

# 启动服务
/etc/init.d/py_signal_fm350 start

# 输出安装成功信息
echo "安装成功并已启动 py_signal_fm350 服务"
