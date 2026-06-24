ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.provider :virtualbox do |v|
    v.memory = 1512
    v.cpus = 2
  end

  boxes = [
    { :name => "log", :ip => "192.168.56.20" },
    { :name => "web", :ip => "192.168.56.25" }
  ]

  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]
      config.vm.network "private_network", ip: opts[:ip]

      if opts[:name] == "web"
        config.vm.provision "shell", inline: <<-SHELL
          # Ожидание, пока log станет доступна по SSH
          echo "Waiting for log VM (192.168.56.20) to be ready for SSH..."
          while ! nc -z 192.168.56.20 22 2>/dev/null; do
            sleep 2
            echo -n "."
          done
          echo ""
          echo "log VM is ready for SSH"

          # Установка Ansible
          sudo apt update
          sudo apt install -y ansible

          # Подготовка директории для Ansible
          mkdir -p /home/vagrant/ansible
          cp /vagrant/ansible/site.yml /home/vagrant/ansible/
          cp /vagrant/ansible/inventory.yml /home/vagrant/ansible/

          # Отключение проверки SSH-ключей
          export ANSIBLE_HOST_KEY_CHECKING=False

          # Запуск плейбука
          cd /home/vagrant/ansible
          ansible-playbook -i inventory.yml site.yml
        SHELL
      end
    end
  end
end
