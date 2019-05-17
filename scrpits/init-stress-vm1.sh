#!/bin/bash
yum install -y epel-release
yum install -y iperf3 fio stress-ng jq python-pip python-devel gcc
yum install -y https://rdoproject.org/repos/rdo-release.rpm
yum install -y centos-release-openstack-queens
yum install -y python-openstackclient
yum update -y
#pip install openstacksdk

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

curl https://gitlab.com/jskandera/hopla.cloud-stress-pub/raw/master/stress.sh --output /usr/sbin/stress.sh
chmod 755 /usr/sbin/stress.sh
# Only for lab
echo "172.25.0.9 s3-fr-lab-1.lab.hopla.cloud" >> /etc/hosts
echo "172.25.0.1 fr-lab-1.lab.hopla.cloud" >> /etc/hosts