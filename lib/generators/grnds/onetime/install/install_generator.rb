require 'rails/generators'

module Grnds
  module Onetime
    class InstallGenerator < Rails::Generators::Base
      def add_migration
        run 'rails g migration create_onetime_scripts version:string:index owner:string description:text completed_at:timestamp changes:text'
      end
    end
  end
end
