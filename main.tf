provider "aws" {
  region  = "eu-central-1"
}



// create ec2 server, use ec2 module
module "myapp-server" {
    source = "./modules/ec2"
    my_ip  = var.my_ip
    instance_type = var.instance_type
    ami = var.ami
    key_name = var.key_name
    public_key_location  = var.public_key_location 
}

// create s3 
module "my-s3" {
    source = "./modules/s3"
    bucket_name = var.bucket_name
    key = var.key
    image_source = var.image_source
    content_type = var.content_type
}


// create cloudFront
module "cloudFront" {
    source = "./modules/cloudFront"
    s3 = module.my-s3.s3
    key = var.key

}


