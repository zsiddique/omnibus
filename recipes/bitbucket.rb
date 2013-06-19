#
# Cookbook Name:: omnibus
# Recipe:: bitbucket
#
# Copyright 2013, Opscode, Inc. Modify by Atlassian
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


return if platform_family?("windows")

ssh_config_file = case node['platform_family']
                  when 'mac_os_x'
                    "/etc/ssh_config"
                  else
                    "/etc/ssh/ssh_config"
                  end

sudoers_file = case node['platform_family']
               when 'freebsd'
                 "/usr/local/etc/sudoers"
               else
                 "/etc/sudoers"
               end


# Turn off strict host key checking for bitbucket
ruby_block "disable strict host key checking for bitbucket.org" do
  block do
    f = Chef::Util::FileEdit.new(ssh_config_file)
    f.insert_line_if_no_match(/bitbucket\.org/, <<-EOH

Host bitbucket.org
  StrictHostKeyChecking no
EOH
    )
    f.write_file
  end
  only_if { ::File.exists?(ssh_config_file) }
end

# Ensure SSH_AUTH_SOCK is honored under sudo
ruby_block "make sudo honor ssh_auth_sock" do
  block do
    f = Chef::Util::FileEdit.new(sudoers_file)
    f.insert_line_if_no_match(/SSH_AUTH_SOCK/, <<-EOH

Defaults env_keep+=SSH_AUTH_SOCK
EOH
    )
    f.write_file
  end
  only_if { ::File.exists?(sudoers_file) }
end
