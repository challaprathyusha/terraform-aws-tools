#creating jenkins controller using terraform aws ec2 opensource module
module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b444882f9979b624"]
  subnet_id              = "subnet-059a0e5a39b8f968b"
  #userdata to configure jenkins in the server
  user_data = file("jenkins.sh")
  tags = {
     Name = "jenkins-tf"
  }
       
}

#creating jenkins agent using terraform aws ec2 opensource module
module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b444882f9979b624"]
  subnet_id              = "subnet-059a0e5a39b8f968b"
  #userdata to configure java in server
  user_data = file("jenkins-agent.sh")
  tags = {
     Name = "jenkins-agent-"
  }
       
}


#creating route53 records for jenkins controller and jenkins agent using opensource module
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins" 
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
         module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    }
  ]

}