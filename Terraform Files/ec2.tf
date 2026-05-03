resource "aws_instance" "web" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "terraform-key"

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Multi-Tier Terraform Project</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server"
  }
}