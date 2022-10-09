output "Jenkins-Host-IP" {
  value = module.dev_jenkins.Jenkins_pubIP
}
output "Docker-Host-IP" {
  value = module.dev_docker.Docker_pubIP
}
output "Ansible-Node-IP" {
  value = module.dev_ansible.Ansible_IP
}
output "sonarQube-IP" {
  value = module.dev_sonarQube.sonarQube_pubIP
}
output "dev_loadbalance" {
  value = module.dev_loadbalance.JenContainer-lb
}
output "dev_route53" {
  value = module.dev_route53.Rout53_NameServer
}