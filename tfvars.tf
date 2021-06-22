#Avaliability Zone - matchs with region
variable "AZ1" {
    type = string
    default = ""
}

#Private key filename
variable "PRIVATE_KEY_FILE_NAME" {
    type = string
    default = ""
}
 
#Name off key saved in AWS
variable "KEY_PUB" {
    default = ""
}

#FQDN
variable "FQDN" {
    default = ""
}

#Zone id in Route53
variable "R53_ZONE" {
    default = ""
}
