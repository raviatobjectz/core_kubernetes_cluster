# -*- mode: ruby -*-
# vi: set ft=ruby :

$num_instances = 3
$instance_name_prefix = "coreos"
$ip_suffix = "192.168.10"
$master_ip = "192.168.10.21"
$instance_name_prefix = "worker"
$master_memory = "1024"
$worker_memory = "512"

Vagrant.configure("2") do |config|
  config.vm.define vm_name = "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "coreos-stable"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = $master_memory
    end
    master.vm.network :private_network, ip: $master_ip
    master.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
    master.vm.provision "shell" do |s|
      s.inline = "cat /home/core/share/flannel_master_template.yaml | sed -e \"s/MASTERIP/$1/g\" > /home/core/flannel_master.yaml"
      s.args   = ["#{$master_ip}"]
    end
    master.vm.provision "shell" do |s|
      s.inline = "cat /home/core/share/etcd_master_template.yaml | sed -e \"s/MASTERIP/$1/g\" > /home/core/etcd_master.yaml"
      s.args   = ["#{$master_ip}"]
    end
    config.vm.provision "shell" do |s|
      s.inline = "cat /home/core/share/kube_master_template.sh | sed -e \"s/MASTERIP/$1/g\" > /home/core/kube_master.sh"
      s.args   = ["#{$master_ip}"]
    end
    master.vm.provision "shell", inline: <<-SHELL
      sudo coreos-cloudinit --from-file /home/core/etcd_master.yaml
      sleep 5s
      /usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "10.1.0.0/16" }'
      sleep 5s
      sudo coreos-cloudinit --from-file /home/core/flannel_master.yaml
      sleep 5s
      chmod +x /home/core/kube_master.sh
      sudo /home/core/kube_master.sh
    SHELL
  end
  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname =  vm_name
      config.vm.box = "coreos-stable"
      config.vm.provider "virtualbox" do |vb|
        vb.memory = $worker_memory
      end
      ip = "#{$ip_suffix}.#{i+100}"
      config.vm.network :private_network, ip: ip
      config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']
      config.vm.provision "shell" do |s|
        s.inline = "cat /home/core/share/flannel_worker_template.yaml | sed -e \"s/MASTERIP/$1/g\" | sed -e \"s/LOCALIP/$2/g\" > /home/core/flannel_worker.yaml"
        s.args   = "#{$master_ip} #{ip}"
      end
      config.vm.provision "shell" do |s|
        s.inline = "cat /home/core/share/kube_worker_template.sh | sed -e \"s/MASTERIP/$1/g\" | sed -e \"s/LOCALIP/$2/g\" > /home/core/kube_worker.sh"
        s.args   = "#{$master_ip} #{ip}"
      end
      config.vm.provision "shell", inline: <<-SHELL
        sudo coreos-cloudinit --from-file /home/core/flannel_worker.yaml
        sleep 5s
        chmod +x /home/core/kube_worker.sh
        sudo /home/core/kube_worker.sh
      SHELL
    end
  end
end
