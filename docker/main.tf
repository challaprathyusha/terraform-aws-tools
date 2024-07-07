#creating docker instance using terraform aws ec2 opensource module
module "docker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "docker"

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0b444882f9979b624"]
  subnet_id              = "subnet-059a0e5a39b8f968b"
  #userdata to configure docker engine in the server
  #user_data = file("docker.sh")
  tags = {
     Name = "docker"
  }
       
}


#creating route53 records for docker using opensource module
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "docker" 
      type    = "A"
      ttl     = 1
      records = [
        module.docker.public_ip
      ]
      allow_overwrite = true
    }
  ]

}