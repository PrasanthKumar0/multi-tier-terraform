resource "aws_launch_template" "web_template" {
  name_prefix   = "web-template"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.micro"
  key_name      = "terraform-key"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Auto Scaling Web Server</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "asg-web-server"
    }
  }
}
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}
