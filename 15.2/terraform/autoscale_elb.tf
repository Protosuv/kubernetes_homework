data "template_file" "bootstrap" {
  template = file("script.tpl")
  vars = {
    url = data.aws_s3_bucket.mybucket.bucket_domain_name
    file = data.aws_s3_bucket_object.img.key
  }
}

resource "aws_launch_configuration" "autoscale_conf" {
  name_prefix   = "homework-"
  image_id      = data.aws_ami.centos.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  security_groups = [aws_security_group.netology-sg.id]
  user_data = data.template_file.bootstrap.rendered
  key_name  = aws_key_pair.laptop.key_name
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "elb-protosuv" {
  name = "elb-protosuv"
  subnets = [aws_subnet.public.id]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 15
  }

  security_groups = [aws_security_group.netology-sg.id]

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "elb-protosuv"
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "autoscaling_group"
  launch_configuration = aws_launch_configuration.autoscale_conf.name
  min_size             = 3
  max_size             = 3

  vpc_zone_identifier  = [aws_subnet.public.id]

  load_balancers = [aws_elb.elb-protosuv.id]

  lifecycle {
    create_before_destroy = true
  }
}