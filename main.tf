
resource "aws_instance" "node1" {
  ami           = "ami-04629cfb3bd2d73f3"
  instance_type = "t2.micro"

  tags = {
    Name = "node1"
  }
}