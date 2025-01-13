##############################################################
# Crea una instancia EC2 para el servidor de aplicaciones a partir de AMI de packer (Nginx, Angular, Node.js)
###########################################################3

resource "aws_instance" "web_server" { # Crea instancias EC2 para servidores web
  count                 = var.web_server_count # Número de instancias a crear, definido en la variable
  ami                   = var.ami_id # ID de la AMI (imagen del sistema operativo) a usar
  instance_type         = var.instance_type # Tipo de instancia EC2 (tamaño y capacidad)
  key_name              = var.key_name # Nombre de la clave SSH para acceso remoto
  tags = { # Etiquetas para identificar cada instancia
    Name = "${var.web_server_name}-${count.index + 1}" # Nombre único para cada instancia basado en su índice
  }

  network_interface { # Configuración de red para cada instancia
    network_interface_id = var.web_server_eni_ids[count.index] # ID de la interfaz de red para la instancia
    device_index         = 0 # Asigna esta interfaz como la principal (index 0)
  }

  connection { # Configuración de la conexión SSH para la provisión remota
    type        = "ssh" # Tipo de conexión: SSH
    user        = "ubuntu" # Usuario para la conexión SSH
    private_key = var.private_key # Clave privada para autenticación SSH
    host        = var.web_server_public_ips[count.index] # IP pública de la instancia
  }

  provisioner "remote-exec" {
    inline = [

      # Iniciar el backend con PM2
      "sudo pm2 start /home/ubuntu/app.js",

      # Generar la URL dinámica con la IP pública
      "BACKEND_URL=http://${self.public_ip}",

      # Sustituir el marcador en app.component.ts
      "sudo sed -i 's|__BACKEND_URL__|'\"$BACKEND_URL\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",

      # Sustituir __NUM_INST__ con el número de instancia
      "sudo sed -i 's|__NUM_INST__|'\"${count.index + 1}\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",

      # Cambiar al directorio del proyecto Angular
      "cd /home/ubuntu/angular-app",

      "sudo npm install",                       # Instala dependencias
      "(sleep 5; echo 'n'; sleep 10; echo 'N') | sudo ng build --configuration=production", # Construye el proyecto sin interacción

      # Crear el directorio en Nginx si no existe
      "sudo mkdir -p /var/www/angular-app/dist",

      # Copiar los archivos generados al directorio que usa Nginx
      "sudo cp -r dist/angular-app/* /var/www/angular-app/dist/",

      # Asegurarse de que los permisos sean correctos
      "sudo chown -R www-data:www-data /var/www/angular-app/dist",
      "sudo chmod -R 755 /var/www/angular-app/dist",

      # Reiniciar Nginx para servir los nuevos archivos
      "sudo systemctl restart nginx",
    ]
  }
}




############################################################3
##############################################################
# Crea una instancia EC2 para MongoDB
###########################################################3
############################################################
resource "aws_instance" "mongodb" { 
  ami                   = var.ami_id # ID de la AMI para el sistema operativo
  instance_type         = var.instance_type # Tipo de instancia EC2
  key_name              = var.key_name # Clave SSH para acceso remoto
  tags = { # Etiqueta para identificar la instancia
    Name = var.mongodb_name # Nombre del servidor MongoDB
  }

  network_interface { # Configuración de red de la instancia
    network_interface_id = var.mongodb_eni_id # ID de la interfaz de red asignada
    device_index         = 0 # Configura esta interfaz como la principal
  }

  connection { # Configuración de conexión SSH para provisión remota
    type        = "ssh" # Tipo de conexión: SSH
    user        = "ubuntu" # Usuario para la conexión SSH
    private_key = var.private_key # Clave privada para autenticación SSH
    host        = var.mongodb_public_ip # IP pública de la instancia
  }

  provisioner "remote-exec" { # Provisión remota para configurar la instancia
    inline = [ # Lista de comandos ejecutados en la instancia
      "sudo apt-get update", # Actualiza los paquetes de software
      "sudo apt-get install -y mongodb", # Instala MongoDB
      "sudo sed -i 's/^bindIp.*/bindIp: 0.0.0.0/' /etc/mongod.conf", # Permite conexiones externas (0.0.0.0)
      "sudo systemctl restart mongod", # Reinicia el servicio MongoDB
      "sudo systemctl enable mongod" # Configura MongoDB para iniciar automáticamente al arrancar
    ]
  }
}