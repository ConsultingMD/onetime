module Grnds
  module Onetime
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/onetime.rake'
      end
    end
  end
end
