provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "hello_sg" {
  name = "hello-world-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hello_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  security_groups = [aws_security_group.hello_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install python3 -y
              pip3 install flask

              cat <<EOT > app.py
              from flask import Flask
              app = Flask(__name__)

              @app.route("/")
              def hello():
                  return "Hello World from Terraform!"

              app.run(host="0.0.0.0", port=80)
              EOT

              python3 app.py
              EOF

  tags = {
    Name = "HelloWorldEC2"
  }
}
