ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
  end

  boxes = [
    { :name => "web", :ip => "192.168.56.10" },
    { :name => "log", :ip => "192.168.56.15" }
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network "private_network", ip: opts[:ip]

      if opts[:name] == "web"
        config.vm.provision "shell", inline: <<-SHELL
          # Установка Ansible
          sudo apt update
          sudo apt install -y ansible

          # Создание директории для Ansible
          mkdir -p /home/vagrant/ansible

          # Копирование плейбука и инвентаря
          cp /vagrant/ansible/site.yml /home/vagrant/ansible/
          cp /vagrant/ansible/inventory.yml /home/vagrant/ansible/

          # Запуск Ansible
          cd /home/vagrant/ansible
          ansible-playbook -i inventory.yml site.yml
        SHELL
      else
        config.vm.provision "shell", inline: <<-SHELL
          echo "log VM is ready"
        SHELL
      end
    end
  end
end
