  # Connect to the Vulnerable instance via Terraform and remotely sets up the scripts using SSH

  provisioner "file" {
    source      = "${var.folder_scripts}/setup.sh"
    destination = "/home/user/ubuntu/setup.sh"
    connection {
      type = "ssh"
      host = aws_instance.vulnerable.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/port_scan.sh"
    destination = "/home/user/ubuntu/port_scan.sh"
    }
  connection {
    type = "ssh"
    host = aws_instance.vulnerable.public_ip
    user = "ubuntu"
    private_key = file(var.ssh_key_path)
  }

  provisioner "file" {
    source      = "${var.folder_scripts}/suspicious_ip.sh"
    destination = "/home/user/ubuntu/suspicious_ip.sh"
    }
  connection {
    type = "ssh"
    host = aws_instance.vulnerable.public_ip
    user = "ubuntu"
    private_key = file(var.ssh_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/user/ubuntu/setup.sh",
      "sudo /home/user/ubuntu/setup.sh"
    ]
    connection {
      type = "ssh"
      host = aws_instance.vulnerable.public_ip
      user = "ubuntu"
      private_key = file(var.ssh_key_path)
    }
  }