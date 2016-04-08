module Grnds
  module Onetime
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/script.rake'
      end
    end
  end
end
