variable "company" {

  type    = string
  default = "dtc"

}
variable "central_subnet" {

  type    = string
  default = "10.0.10.0/24"

}

variable "west_subnet" {

  type    = string
  default = "10.0.20.0/24"

}

variable "east_subnet" {

  type    = string
  default = "10.0.30.0/28"

}

variable "project_id" {

  type    = string
  default = "Project_id"

}

variable "env" {

  type    = string
  default = "dev"
}


