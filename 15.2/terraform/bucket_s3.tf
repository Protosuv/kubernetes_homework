resource "aws_s3_bucket" "mybucket" {
  bucket = "suvorov-netology"
  acl    = "private"
  versioning {
    enabled = false
  }
  tags = { 
      Name = "My S3 bucket" 
    }
}

resource "aws_s3_bucket_object" "img" {
  bucket = "suvorov-netology"
  acl    = "public-read"
  key    = "file1.png"
  source = "file/file1.png"
  
}
data "aws_s3_bucket" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id
}

data "aws_s3_bucket_object" "img" {
  bucket = aws_s3_bucket.mybucket.id
  key    = aws_s3_bucket_object.img.id
}