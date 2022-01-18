output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws-id-private-subnet" {
  value = aws_subnet.private.id
}

output "aws-id-public-subnet" {
  value = aws_subnet.public.id
}

output "region" {
  value = "us-east-2"
}
output "url" {
  value = data.aws_s3_bucket.mybucket.bucket_domain_name
}
output "file" {
  value = data.aws_s3_bucket_object.img.key
}
output "load_balancer_name" {
  value = "${aws_elb.elb-protosuv.dns_name}"
}