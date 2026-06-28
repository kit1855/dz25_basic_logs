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
        # Копируем Ansible-файлы на master
        config.vm.provision "file", source: "./ansible", destination: "/home/vagrant/ansible"

        # Основной провижинг
        config.vm.provision "shell" do |shell|
          shell.inline = <<-SHELL
            # Установка Ansible и sshpass
            apt update
            apt install -y ansible sshpass

            # Генерация SSH-ключа
            ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""

            # Добавление хостов в known_hosts
            ssh-keyscan 192.168.56.10 >> /home/vagrant/.ssh/known_hosts
            ssh-keyscan 192.168.56.15 >> /home/vagrant/.ssh/known_hosts

            # Копирование ключей на web и log
            sshpass -p "vagrant" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.56.10
            sshpass -p "vagrant" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub vagrant@192.168.56.15

            # Запуск Ansible playbook
            cd /home/vagrant/ansible
            ansible-playbook -i inventory.yml playbook.yml -v
          SHELL
        end
      end
    end
  end
end
