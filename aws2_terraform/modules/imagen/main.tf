#################################################################################################
# EJECUTA PACKER PARA CREAR LA IMAGEN BASE DEL SISTEMA
####################################################################################################
# RECURSO PARA EJECUTAR PACKER Y GENERAR LA AMI
# Este recurso utiliza un comando local (en la maquina que ejecuta terraform init) para ejecutar Packer con las variables necesarias
# y generar la AMI basada en el archivo de configuración de Packer (main.pkr.hcl).
resource "null_resource" "packer_ami" {
  # local-exec ejecuta un comando en la máquina que ejecuta Terraform.
      # Este comando invoca Packer para construir una AMI personalizada usando las variables y configuraciones proporcionadas.
  provisioner "local-exec" {

    command = "packer build -var aws_access_key=${var.aws_access_key} -var aws_secret_key=${var.aws_secret_key} -var aws_session_token=${var.aws_session_token} -var-file=../aws_packer/variables.pkrvars.hcl ../aws_packer/main.pkr.hcl"

  }
}

####################################################################################################
# OBTENER LA ÚLTIMA AMI CREADA
####################################################################################################
data "aws_ami" "latest_ami" {
  
  depends_on = [null_resource.packer_ami] # Espera a que el provisioner "packer_ami" termine --> asegura que la AMI sea creada antes de intentar recuperarla.
  most_recent = true                      # Selecciona siempre la AMI más reciente.
  filter {
    name   = "name"                       # Filtra por el nombre de la AMI.
    values = ["${var.ami_name}*"]         # Busca nombres que coincidan parcialmente con el valor de la variable `ami_name`.
  }
  owners = ["self"]                       # Limita la búsqueda a las AMIs creadas por el propietario actual.
}