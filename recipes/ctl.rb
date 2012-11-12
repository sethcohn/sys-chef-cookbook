#
# Cookbook Name:: linux
# Recipe:: sysctl
#
# Copyright 2012, Victor Penso
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


node.sys.ctl.each do |name,values|

  filename = "/etc/sysctl.d/#{name.gsub(/\./,'_')}.conf"
  sysctl = "Set Linux kernel variables from #{filename}"

  # transform the configuration for JSON attributes to sysctl format
  config = String.new
  values.each do |key,value|
    config << "#{name}.#{key}=#{value}\n"
  end

  # write the configuration file
  file filename do
    content config
    mode 644
    notifies :run, "execute[#{sysctl}]", :immediately
  end

  execute sysctl do
    action :nothing
    command %Q[sysctl --load #{filename} 1>-]
  end

end

