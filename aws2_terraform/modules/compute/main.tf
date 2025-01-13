resource "aws_instance" "web_server" {
  count                 = var.web_server_count
  ami                   = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  tags = {
    Name = "${var.web_server_name}-${count.index + 1}"
  }

  network_interface {
    network_interface_id = var.web_server_eni_ids[count.index]
    device_index         = 0
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = var.web_server_public_ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo 'Hello from Web Server ${count.index + 1}' > /var/www/html/index.html",
      "sudo systemctl restart nginx"
    ]
  }
}

resource "aws_instance" "mongodb" {
  ami                   = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  tags = {
    Name = var.mongodb_name
  }

  network_interface {
    network_interface_id = var.mongodb_eni_id
    device_index         = 0
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = var.mongodb_public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mongodb",
      "sudo sed -i 's/^bindIp.*/bindIp: 0.0.0.0/' /etc/mongod.conf",
      "sudo systemctl restart mongod",
      "sudo systemctl enable mongod"
    ]
  }
}
