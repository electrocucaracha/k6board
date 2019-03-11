# -*- mode: ruby -*-
# vi: set ft=ruby :
##############################################################################
# Copyright (c
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

box = {
  :virtualbox => { :name => 'generic/centos7', :version=> '1.9.2' },
  :libvirt => { :name => 'centos/7', :version=> '1901.01' }
}

if ENV['no_proxy'] != nil or ENV['NO_PROXY']
  $no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
  $subnet = "192.168.121"
  # NOTE: This range is based on vagrant-libvirt network definition CIDR 192.168.121.0/27
  (1..31).each do |i|
    $no_proxy += ",#{$subnet}.#{i}"
  end
end


Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox
  config.vm.provision 'shell', privileged: false do |sh|
    sh.inline = <<-SHELL
      cd /vagrant/
      ./installer.sh | tee krd_installer.log
    SHELL
  end

  config.vm.provider :virtualbox do |v, override|
    override.vm.box =  box[:virtualbox][:name]
    override.vm.box_version = box[:virtualbox][:version]
    v.customize ["modifyvm", :id, "--memory", 8192]
    v.customize ["modifyvm", :id, "--cpus", 4]
  end

  config.vm.provider :libvirt do |v, override|
    override.vm.box =  box[:libvirt][:name]
    override.vm.box_version = box[:libvirt][:version]
    v.memory = 8192
    v.cpus = 4
    v.nested = true
    v.cpu_mode = 'host-passthrough'
    v.management_network_address = "192.168.121.0/27"
  end

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil
    if Vagrant.has_plugin?('vagrant-proxyconf')
      config.proxy.http     = ENV['http_proxy'] || ENV['HTTP_PROXY'] || ""
      config.proxy.https    = ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ""
      config.proxy.no_proxy = $no_proxy
      config.proxy.enabled = { docker: false }
    end
  end
end
