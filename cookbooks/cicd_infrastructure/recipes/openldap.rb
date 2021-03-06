# Encoding: utf-8
#
# Cookbook Name:: cicd_infrastructure
# Recipe:: openldap
#
# Copyright (c) 2014 Grid Dynamics International, Inc. All Rights Reserved
# Classification level: Public
# Licensed under the Apache License, Version 2.0.
#

include_recipe 'iptables::default'

iptables_rule 'allow_private_ips'

user 'openldap' do
  action :create
  gid 'users'
  shell '/bin/bash'
end

group 'openldap' do
  action :create
  members ['openldap']
end

include_recipe 'openldap::server'

service 'slapd' do
  action :nothing
end

template "#{node['openldap']['dir']}/ldap.conf" do
  source 'openldap/ldap.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
end

file "#{node['openldap']['dir']}/slapd.d/cn=config/olcDatabase={2}bdb.ldif" do
  action :delete
  notifies :restart, 'service[slapd]'
end

include_recipe 'cicd_infrastructure::openldap_init_root'

unless node['platform'].eql?('ubuntu')
  ldap_client = resources({:package => 'ldap-utils'})
  ldap_client.name('openldap-clients')
  ldap_client.package_name('openldap-clients')
  ldap_client.action(:upgrade)

  db_util = resources({:package => 'db4.2-util'})
  db_util.action(:nothing)

  ldap_server = resources({:package => 'slapd'})
  ldap_server.name('openldap-servers')
  ldap_server.package_name('openldap-servers')
  ldap_server.action(:upgrade)
end

include_recipe 'phpldapadmin-cookbook::default'
