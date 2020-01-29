variable "ae_private_subnet" {

    type = string
    default = "10.0.10.0/24"

}
variable "as_private_subnet" {
    type = string
    default = "10.0.20.0/24"
  
}

variable "project_id" {
   
   default = "my-test-project-2020-264310"
}

variable "company" {
  
  default = "dtc"
}

variable "env" {
  default = "dev"
}





