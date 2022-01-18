resource "aws_route53_zone" "dns" {
  name = "suvorov-netology.local"
  vpc {
    vpc_id = aws_vpc.netology-vpc.id
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.dns.zone_id
  name    = "www.suvorov-netology.local"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.elb-protosuv.dns_name]
}
