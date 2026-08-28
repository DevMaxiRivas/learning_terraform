#!/bin/bash
echo "Running the Setup Script"

dnf install awscli -y
dnf install -y amazon-cloudwatch-agent

# Set log file
touch /var/log/myapp.log
chmod 644 /var/log/myapp.log
echo "Log inicializado el $(date)" >> /var/log/myapp.log

# Set configuration aws
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/myapp.log",
            "log_group_name": "/aws/ec2/instances",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 30
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \

# Run agent from binary file
/opt/aws/amazon-cloudwatch-agent/bin/start-amazon-cloudwatch-agent

echo "Agent run successfully"