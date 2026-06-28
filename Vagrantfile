ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
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
            # Установка Ansible и sshpass
            apt update
            apt install -y ansible sshpass

            # Генерация SSH-ключа для пользователя vagrant
            sudo -u vagrant ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""

            # Добавление хостов в known_hosts для пользователя vagrant
            sudo -u vagrant ssh-keyscan 192.168.56.10 >> /home/vagrant/.ssh/known_hosts
            sudo -u vagrant ssh-keyscan 192.168.56.15 >> /home/vagrant/.ssh/known_hosts

            # Копирование ключей на web и log (от имени vagrant)
            sudo -u vagrant sshpass -p "vagrant" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.56.10
            sudo -u vagrant sshpass -p "vagrant" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.56.15

            # Проверка подключения (для отладки)
            sudo -u vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 "echo 'Connected to web'"
            sudo -u vagrant ssh -o StrictHostKeyChecking=no vagrant@192.168.56.15 "echo 'Connected to log'"

            # Запуск Ansible playbook от имени vagrant
            cd /home/vagrant/ansible
            sudo -u vagrant ansible-playbook -i inventory.yml playbook.yml -v
          SHELL
        end
      end
    end
  end
end
