# Encoding: utf-8
#
# Cookbook Name:: cicd_infrastructure
# Recipe:: nexus
#
# Copyright (c) 2014 Grid Dynamics International, Inc. All Rights Reserved
# Classification level: Public
# Licensed under the Apache License, Version 2.0.
#

Chef::Config[:file_cache_path] = '/var/chef/cache/'

include_recipe 'nexus::default'

if node['cicd_infrastructure']['nexus']['auth'] == 'LDAP'
  include_recipe 'cicd_infrastructure::nexus_ldap'
end

nexus_config = node['cicd_infrastructure']['nexus']

template '/nexus/sonatype-work/nexus/conf/nexus.xml' do
  source 'nexus/nexus.xml.erb'
  owner 'root'
  group 'root'
  mode 0644
variables(
    buid_repo_id:	    nexus_config['repo']['build']['id'],
    buid_repo_name:	    nexus_config['repo']['build']['name'],
    buid_repo_policy:	    nexus_config['repo']['build']['policy'],
    buid_repo_ttl:	    nexus_config['repo']['build']['ttl'],
    promote_repo_id:	    nexus_config['repo']['promote']['id'],
    promote_repo_name:	    nexus_config['repo']['promote']['name'],
    promote_repo_policy:    nexus_config['repo']['promote']['policy'],
    promote_repo_ttl:	    nexus_config['repo']['promote']['ttl']
  )
end
