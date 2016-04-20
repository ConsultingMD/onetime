require 'rails/generators'

module Grnds
  class OnetimeGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def onetime_script
      @now = Time.now

      template 'onetime_script.rb.erb', "script/onetime/#{stringified_timestamp}_#{file_name}.rb"
    end

    def stringified_timestamp
      @now.strftime '%Y%m%d%H%M%S'
    end

    def owner_body
      git_name = `git config user.name`.chomp
      git_email = `git config user.email`.chomp

      (git_name.to_s.empty? && git_email.to_s.empty?)? nil : "\"#{git_name} (#{git_email})\""
    end
  end
end
