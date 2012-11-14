#
# Cookbook Name:: linux
# Recipe:: network
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

interfaces = node.sys.network.interfaces

unless interfaces.empty?

  package 'vlan'
  package 'bridge-utils'

  directory '/etc/network/interfaces.d'

  cookbook_file '/etc/network/interfaces' do
    source 'etc_network_interfaces'
  end

  interfaces.each do |name,params|

    inet = params.has_key?(:inet) ? params[:inet] : 'manual'
    params.delete(:inet)
    
    if name == node.network.default_interface and inet == 'static'
      params[:address] = node.ipaddress unless params.has_key?(:address)
      params[:gateway] = node.network.default_gateway unless params.has_key?(:gateway)
      params[:broadcast] = node.network.interfaces[node.network.default_interface].addresses[params[:address]].broadcast unless params.has_key?(:broadcast)
      params[:netmask] = node.network.interfaces[node.network.default_interface].addresses[params[:address]].netmask unless params.has_key?(:netmask)
    end

    config = Array.new
    params.each { |key,value| config << "  #{key} #{value}" }
   
    template "/etc/network/interfaces.d/#{name}" do
      source 'etc_network_interfaces.d_generic.erb'
      mode 644
      variables(
        :name => name,
        :inet => inet,
        :config => config
      )
    end
  
  end

end
