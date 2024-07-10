#creating jenkins controller using terraform aws ec2 opensource module
module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "jenkins-controller"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0b444882f9979b624"]
  subnet_id              = "subnet-059a0e5a39b8f968b"
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 50
    }
  ]
  #userdata to configure jenkins in the server
  user_data = file("jenkins.sh")
  tags = {
     Name = "jenkins-controller"
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
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 50
    }
  ]
  #userdata to configure java in server
  user_data = file("jenkins-agent.sh")
  tags = {
     Name = "jenkins-agent-"
  }
       
}


#resource block to import public key into aws
resource "aws_key_pair" "deployer" {
  key_name   = "nexus"
  public_key = file("~/.ssh/nexuskey.pub")
  # ~ means windows home directory
  # we can directly paste the public key as below or we can give the location of the key as above
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZXn4zW9oTBMKiA8JrNVUtmmlzCZEH1kQfYlSlXNJzVhHLj4YOsMj1pyuNIqn4vjzG/OzirHS2Y9P0ycv25YUSV+i32kt8+cHDTjMd5MNBGdecF1kOaG5azucnWADS5AMSp4uT/18LE+RKvFMWUfrMQiFaRIbZ72Sd7VMrxNssyPlSEZuk09QUFErkzaPWnymFUDiHMJTNMxxjAB7RmuxChjVVOsle/N3eFhlm7TCL70sGLBrRBjUDfuHhYuWxZKt2P9F5Vv2a1MXRXM6xYELa1MuT3bxUmSp0tiaEenr7ZR1yBApmRXtDtDBO7ML714CMtuS8UUAjZzRw0Fee4gGegQHRd/64Q9+DsyDri4ZGUTm8g0i4ATqSfTTmzy0nx2GuGTwAwBBpW0t9Px8goH++WWZX8gEFMwbQkhxREH8tZSLee74Tj2Jr+/DJm3SlnPwrLPZFslOAxtmSKRFSuu8kMJU9ls8Adxo/Yi04DYlxJSDdynO0yckSw9I6QXhDS8M= 91630@PrathyuPavan"
}

#creating nexus server using terraform aws ec2 opensource module
#nexus runs on 8081 port
#username=ubuntu and keypair to login to nexus server
module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.nexus_ami_info.id
  name = "nexus"
  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0b444882f9979b624"]
  subnet_id              = "subnet-059a0e5a39b8f968b"
  key_name = aws_key_pair.deployer.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}

#creating route53 records for jenkins controller,jenkins agent and nexus server using opensource module
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
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      records = [
         module.nexus.private_ip
      ]
      allow_overwrite = true
    }
  ]

}