ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  # Базовая конфигурация
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.memory = 1512
    v.cpus = 2
  end

  # Описание двух ВМ
  boxes = [
    { :name => "web", :ip => "192.168.56.10" },
    { :name => "log", :ip => "192.168.56.15" }
  ]

  # Провижининг каждой ВМ
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network "private_network", ip: opts[:ip]

      # Дополнительный провижининг для web (установка nginx)
      if opts[:name] == "web"
        config.vm.provision "shell", inline: <<-SHELL
          apt update && apt install -y nginx
          systemctl enable nginx
          systemctl start nginx
        SHELL
      end

      # Запуск Ansible после создания последней ВМ (log)
      if opts[:name] == boxes.last[:name]
        config.vm.provision "ansible" do |ansible|
          ansible.playbook = "/vagrant/ansible/site.yml"
          ansible.inventory_path = "/vagrant/ansible/inventory.yml"
          ansible.host_key_checking = "false"
          ansible.limit = "all"
          ansible.verbose = "v"
        end
      end
    end
  end
end
