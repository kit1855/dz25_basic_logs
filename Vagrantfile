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
            # Установка Ansible
            apt update
            apt install -y ansible

            # Копирование Vagrant-ключей с хоста на master
            mkdir -p /home/vagrant/.ssh
            cp /vagrant/.vagrant/machines/web/virtualbox/private_key /home/vagrant/.ssh/web_key
            cp /vagrant/.vagrant/machines/log/virtualbox/private_key /home/vagrant/.ssh/log_key
            chmod 600 /home/vagrant/.ssh/*_key

            # Создание SSH-конфига для использования этих ключей
            cat > /home/vagrant/.ssh/config <<EOF
Host web
    HostName 192.168.56.10
    User vagrant
    IdentityFile /home/vagrant/.ssh/web_key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host log
    HostName 192.168.56.15
    User vagrant
    IdentityFile /home/vagrant/.ssh/log_key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
            chmod 600 /home/vagrant/.ssh/config

            # Проверка подключения
            ssh -T web "echo 'Connected to web'"
            ssh -T log "echo 'Connected to log'"

            # Запуск Ansible playbook
            cd /home/vagrant/ansible
            ansible-playbook -i inventory.yml playbook.yml -v
          SHELL
        end
      end
    end
  end
end
