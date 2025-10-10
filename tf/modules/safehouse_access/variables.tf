variable "backend" {
  type = string
}

variable "app_name" {
  type = string
}

variable "policies" {
  type = list(string)
  default = ["default", "app"]
}
