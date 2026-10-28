resource "aws_s3_bucket" "uploads" {
  bucket = "example-uploads-bucket"
  acl    = "public-read"
}

resource "aws_security_group" "open_ssh" {
  name = "open-ssh"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"
}
