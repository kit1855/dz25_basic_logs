ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.cpus = 2
  end

  boxes = [
    { :name => "web",    :ip => "192.168.56.10" },
    { :name => "log",    :ip => "192.168.56.15" },
    { :name => "master", :ip => "192.168.56.5" }
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network "private_network", ip: opts[:ip]

      if opts[:name] == "master"
        config.vm.provision "file", source: "./ansible", destination: "/home/vagrant/ansible"
        config.vm.provision "shell" do |shell|
          shell.inline = <<-SHELL
            apt update
            apt install -y ansible sshpass

            # Добавляем хосты в known_hosts
            ssh-keyscan 192.168.56.10 >> /home/vagrant/.ssh/known_hosts
            ssh-keyscan 192.168.56.15 >> /home/vagrant/.ssh/known_hosts

            # Копируем ключи с помощью пароля
            sshpass -p "vagrant" ssh-copy-id vagrant@192.168.56.10
            sshpass -p "vagrant" ssh-copy-id vagrant@192.168.56.15

            cd /home/vagrant/ansible
            ansible-playbook -i inventory.yml playbook.yml -v
          SHELL
        end
      end
    end
  end
end
