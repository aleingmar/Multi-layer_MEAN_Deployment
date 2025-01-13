# Ejecutar Packer para generar una AMI personalizada
resource "null_resource" "packer_ami" {
  provisioner "local-exec" {
    # Ejecuta Packer con las variables necesarias
    command = "packer build -var aws_access_key=${var.aws_access_key} -var aws_secret_key=${var.aws_secret_key} -var aws_session_token=${var.aws_session_token} -var-file=${var.packer_var_file} ${var.packer_template_file}"
  }
}

# Obtener la última AMI creada
data "aws_ami" "latest_ami" {
  depends_on = [null_resource.packer_ami] # Asegura que Packer haya creado la AMI antes de buscarla
  most_recent = true                      # Selecciona la AMI más reciente
  filter {
    name   = "name"
    values = ["${var.ami_name}*"]         # Coincide con el patrón de nombre definido
  }
  owners = ["self"]                       # Limita la búsqueda a las AMIs del propietario actual
}
