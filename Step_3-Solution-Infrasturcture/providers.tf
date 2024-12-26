provider "aws" {
  region = "us.east.1"
}

provider "docker"{
    registry_auth{
        addres = ""
        username = ""
        password = ""
        aws_ecr_repository = ""
    }
}