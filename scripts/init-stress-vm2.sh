#!/bin/bash
yum install -y epel-release
yum install -y iperf3
cat > /etc/systemd/system/iperf3-server.service << EOF
[Unit]
Description=Start iperf3 server
After=network.target
[Service]
Type=oneshot
ExecStart=/root/start-iperf.sh
RemainAfterExit=true
StandardOutput=journal
[Install]
WantedBy=multi-user.target
EOF

cat > /root/start-iperf.sh << EOF
#!/bin/bash
wall "Iperf server"
iperf3 -s -D
EOF

chmod 755 /etc/systemd/system/iperf3-server.service
chmod 755 /root/start-iperf.sh
systemctl daemon-reload
systemctl enable iperf3-server.service
systemctl start iperf3-server.service
