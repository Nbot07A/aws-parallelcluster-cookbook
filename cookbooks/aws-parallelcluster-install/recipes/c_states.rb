# frozen_string_literal: true

#
# Cookbook:: aws-parallelcluster-install
# Recipe:: c_states
#
# Copyright:: 2013-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the
# License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

return unless node['kernel']['machine'] == 'x86_64'

regen_grub_command = value_for_platform(
  %w(centos amazon) => { 'default' => '/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg' },
  'ubuntu' => { 'default' => '/usr/sbin/update-grub' }
)

# Utility function to add an attribute in GRUB_CMDLINE_LINUX_DEFAULT if it is not present
def append_if_not_present_grub_cmdline(attributes)
  grub_variable = value_for_platform(
    %w(centos amazon) => { 'default' => 'GRUB_CMDLINE_LINUX_DEFAULT' },
    'ubuntu' => { 'default' => 'GRUB_CMDLINE_LINUX' }
  )

  grep_grub_cmdline = 'grep "^' + grub_variable + '=" /etc/default/grub'

  ruby_block "Append #{grub_variable} if it do not exist in /etc/default/grub" do
    block do
      if shell_out(grep_grub_cmdline).stdout.include? "#{grub_variable}="
        Chef::Log.debug("Found #{grub_variable} line")
      else
        Chef::Log.warn("#{grub_variable} not found - Adding")
        shell_out('echo \'' + grub_variable + '=""\' >> /etc/default/grub')
        Chef::Log.info("Added #{grub_variable} line")
      end
    end
    action :run
  end
  attributes.each do |attribute, properties|
    ruby_block "Add #{attribute} with value #{properties['value']} to /etc/default/grub in line #{grub_variable} if it is not present" do
      block do
        command_out = shell_out(grep_grub_cmdline).stdout
        if command_out.include? "#{attribute}"
          Chef::Log.warn("Found #{attribute} in #{grub_variable} - #{grub_variable} value: #{command_out}")
        else
          Chef::Log.info("#{attribute} not found - Adding")
          shell_out('sed -i \'s/^\(' + grub_variable + '=".*\)"$/\1 ' + attribute + '=' + properties['value'] + '"/g\' /etc/default/grub')
          Chef::Log.info("Added #{attribute}=#{properties['value']} to #{grub_variable}")
        end
      end
      action :run
    end
  end
end

grub_cmdline_attributes = {
  "processor.max_cstate" => { "value" => "1" },
  "intel_idle.max_cstate" => { "value" => "1" },
}

append_if_not_present_grub_cmdline(grub_cmdline_attributes)

execute "Regenerate grub boot menu" do
  command regen_grub_command
end
