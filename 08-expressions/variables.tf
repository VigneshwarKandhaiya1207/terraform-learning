variable "number_list" {
  type = list(number)

}

variable "number_map" {
  type = map(number)
}

variable "object_list" {
  type = list(object({
    firstname = string
    lastname  = string
  }))
}

variable "user" {
  type = list(object({
    username = string
    role     = string
  }))
}

variable "user_to_output" {
  type = string
}