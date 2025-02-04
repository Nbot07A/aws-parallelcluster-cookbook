# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster-scheduler-plugin
# Recipe:: install_user
#
# Copyright:: 2013-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Setup scheduler-plugin group
group node['cluster']['scheduler_plugin']['group'] do
  comment 'ParallelCluster scheduler plugin group'
  gid node['cluster']['scheduler_plugin']['group_id']
  system true
end

# Setup scheduler-plugin user
user node['cluster']['scheduler_plugin']['user'] do
  comment 'ParallelCluster scheduler plugin user'
  uid node['cluster']['scheduler_plugin']['user_id']
  gid node['cluster']['scheduler_plugin']['group_id']
  # home is mounted from the head node
  manage_home true
  home "/home/#{node['cluster']['scheduler_plugin']['user']}"
  system true
  shell '/bin/bash'
end

bash "set virtualenv in scheduler plugin user bash profile " do
  user node['cluster']['scheduler_plugin']['user']
  code <<-PROFILE
    echo "PATH=#{node['cluster']['scheduler_plugin']['virtualenv_path']}/bin:\\$PATH" >> "#{node['cluster']['scheduler_plugin']['home']}/.bash_profile"
    echo "export PATH" >> "#{node['cluster']['scheduler_plugin']['home']}/.bash_profile"
  PROFILE
end
