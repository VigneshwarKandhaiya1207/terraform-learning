resource "random_id" "bucket-suffix" {
  byte_length = 6

}

resource "aws_s3_bucket" "example-bucket" {
  bucket = "terraform-bucket-testing-${random_id.bucket-suffix.hex}"

}

output "bucket_name" {
  value = aws_s3_bucket.example-bucket.bucket
}