data "cato_allocatedIp" "primary" {
  name_filter = [var.primary_cato_pop_ip]
}

data "cato_allocatedIp" "secondary" {
  name_filter = [var.secondary_cato_pop_ip]
}