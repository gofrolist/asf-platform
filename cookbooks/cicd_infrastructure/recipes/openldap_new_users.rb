# Encoding: utf-8
#
# Cookbook Name:: cicd_infrastructure
# Recipe:: openldap_new_users
#
# Copyright (c) 2014 Grid Dynamics International, Inc. All Rights Reserved
# Classification level: Public
# Licensed under the Apache License, Version 2.0.
#

node['openldap']['users'].each do |record|
  template "#{Chef::Config[:file_cache_path]}/user_#{record.username}.ldif" do
    source 'openldap/new_user.ldif.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      basedn: node['openldap']['basedn'],
      username: record.username,
      password: record.password,
      groups: record.groups
    )
  end

  bash "create ldap_user[#{record.username}]" do
    user 'root'
    code <<-EOH
    ldapadd -x \
      -w #{node['openldap']['rootpw']} \
      -D "cn=admin,#{node['openldap']['basedn']}" \
      -f #{Chef::Config[:file_cache_path]}/user_#{record.username}.ldif
    EOH
    only_if do
      File.exist?(
        "#{Chef::Config[:file_cache_path]}/user_#{record.username}.ldif")
    end
  end
end
