# Elastic Network Interfaces (ENI) para Web Servers
resource "aws_network_interface" "web_server_eni" {
  count           = var.web_server_count
  subnet_id       = var.web_server_subnet_id
  private_ips     = [for i in range(var.web_server_count) : "${var.web_server_private_ip_base}.${i + 10}"]
  #private_ips = ["172.31.16.${count.index + 10}"] # IPs dinámicas: 172.31.16.10, 172.31.16.11
  security_groups = [var.web_server_security_group_id]

  tags = {
    Name = "Web-Server-ENI-${count.index + 1}"
  }
}

resource "aws_eip" "web_server_eip" {
  count             = var.web_server_count
  network_interface = aws_network_interface.web_server_eni[count.index].id

  tags = {
    Name = "Web-Server-EIP-${count.index + 1}"
  }
}

# Elastic Network Interface (ENI) para MongoDB
resource "aws_network_interface" "mongodb_eni" {
  subnet_id       = var.mongodb_subnet_id
  private_ips     = [var.mongodb_private_ip]
  security_groups = [var.mongodb_security_group_id]

  tags = {
    Name = "MongoDB-ENI"
  }
}

resource "aws_eip" "mongodb_eip" {
  network_interface = aws_network_interface.mongodb_eni.id

  tags = {
    Name = "MongoDB-EIP"
  }
}

# Instancias EC2 para Web Servers
resource "aws_instance" "web_server" {
  count                 = var.web_server_count
  ami                   = var.web_server_ami
  instance_type         = var.instance_type
  key_name              = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.web_server_eni[count.index].id
    device_index         = 0
  }

  tags = {
    Name = "${var.web_server_instance_name}-${count.index + 1}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.ssh_private_key
    host        = aws_eip.web_server_eip[count.index].public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo pm2 start /home/ubuntu/app.js",
      "BACKEND_URL=http://${self.public_ip}",
      "sudo sed -i 's|__BACKEND_URL__|'\"$BACKEND_URL\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",
      "sudo sed -i 's|__NUM_INST__|'\"${count.index + 1}\"'|g' /home/ubuntu/angular-app/src/app/app.component.ts",
      "cd /home/ubuntu/angular-app",
      "sudo npm install",
      "(sleep 5; echo 'n'; sleep 10; echo 'N') | sudo ng build --configuration=production",
      "sudo mkdir -p /var/www/angular-app/dist",
      "sudo cp -r dist/angular-app/* /var/www/angular-app/dist/",
      "sudo chown -R www-data:www-data /var/www/angular-app/dist",
      "sudo chmod -R 755 /var/www/angular-app/dist",
      "sudo systemctl restart nginx"
    ]
  }
}

# Instancia EC2 para MongoDB
resource "aws_instance" "mongodb" {
  ami                   = var.mongodb_ami
  instance_type         = var.instance_type
  key_name              = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.mongodb_eni.id
    device_index         = 0
  }

  tags = {
    Name = "MongoDB-Instance"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.ssh_private_key
    host        = aws_eip.mongodb_eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mongodb",
      "sudo sed -i 's/^bind_ip.*/bind_ip = 0.0.0.0/' /etc/mongodb.conf",
      "sudo systemctl restart mongodb",
      "sudo systemctl enable mongodb"
    ]
  }
}
