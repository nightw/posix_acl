#
# Cookbook Name:: posix-acl
# Provider:: default
#
# Copyright 2013, Pal David Gergely
#
# Apache License 2.0
#

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

action :create do
  act('create') do
    converge_by("Create #{@new_resource}") do
      execute setfacl_command
    end
  end
end

action :check do
  act('check') {}
end

def act(message)
  if !Pathname.new(@new_resource.path).exist?
    Chef::Log.warn "Cannot #{message} ACL on '#{@new_resource.path}', because the file or directory does not exist."
  elsif !@new_resource.user.nil? && !@new_resource.group.nil?
    Chef::Log.warn "Cannot #{message} ACL on '#{@new_resource.path}', because either the user attribute or the group attribute should be set, not both."
  elsif @new_resource.user.nil? && @new_resource.group.nil?
    Chef::Log.warn "Cannot #{message} ACL on '#{@new_resource.path}', because the user and the group attributes are both nil."
  elsif @current_resource.exists
    Chef::Log.info "ACL '#{acl_string}' on '#{@new_resource.path}' already set - nothing to do."
  else
    yield
    @new_resource.updated_by_last_action(true)
  end
end

def setfacl_command
    "setfacl #{@new_resource.recursive ? '-R ' : ''}-m #{acl_string} #{@new_resource.path}"
end

def acl_string(for_grep = false)
  if !@new_resource.user.nil?
    "#{@new_resource.default ? (for_grep ? 'default:' : 'd:') : ''}#{for_grep ? 'user' : 'u'}:#{@new_resource.user}:#{@new_resource.read ? 'r' : '-'}#{@new_resource.write ? 'w' : '-'}#{@new_resource.execute ? 'x' : '-'}"
  elsif !@new_resource.group.nil?
    "#{@new_resource.default ? (for_grep ? 'default:' : 'd:') : ''}#{for_grep ? 'group' : 'g'}:#{@new_resource.group}:#{@new_resource.read ? 'r' : '-'}#{@new_resource.write ? 'w' : '-'}#{@new_resource.execute ? 'x' : '-'}"
  else
    ""
  end
end

def load_current_resource
  if !@new_resource.recursive
    @current_resource = Chef::Resource::Acl.new(@new_resource.path)
    @current_resource.path(@new_resource.path)
    @current_resource.user(@new_resource.user)
    @current_resource.group(@new_resource.group)
    @current_resource.default(@new_resource.default)
    @current_resource.read(@new_resource.read)
    @current_resource.write(@new_resource.write)
    @current_resource.execute(@new_resource.execute)
    return_val = shell_out("getfacl --absolute-names #{@current_resource.path} | grep -x #{acl_string(true)}")
    if return_val.exitstatus == 1
      # There were no matches with grep, so the resource does not exists
      @current_resource.exists = false
    elsif return_val.exitstatus == 0
      @current_resource.exists = true
    end
  else
    @current_resource.exists = false
  end
end
