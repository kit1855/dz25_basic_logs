ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
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
          # Wait for log VM to be ready
          echo "Waiting for log VM (192.168.56.20) to be ready for SSH..."
          while ! ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no vagrant@192.168.56.20 "echo 'SSH ready'" 2>/dev/null; do
            sleep 2
            echo -n "."
          done
          echo ""
          echo "log VM is ready for SSH"

          # Install Ansible
          sudo apt update
          sudo apt install -y ansible

          # Prepare Ansible directory
          mkdir -p /home/vagrant/ansible
          cp /vagrant/ansible/site.yml /home/vagrant/ansible/
          cp /vagrant/ansible/inventory.yml /home/vagrant/ansible/

          # Disable SSH key checking for the first connection
          export ANSIBLE_HOST_KEY_CHECKING=False

          # Run playbook
          cd /home/vagrant/ansible
          ansible-playbook -i inventory.yml site.yml
        SHELL
      end
    end
  end
end
