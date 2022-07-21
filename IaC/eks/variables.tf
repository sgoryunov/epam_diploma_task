variable "vpc_id" {
    type = string
}
variable "region" {
  default     = "eu-north-1"
  description = "AWS region"
}

variable "domain_name" {
    default = "itunes-gr.ru"
    type = string
}
    
variable "db_user" {
    type = string
    default = "itunesUser"
}
variable "db_name" {
    type = string
    default = "itunesData"
}
variable "db_user_pass" {
    type = string
    default = "itunesSecret"
}