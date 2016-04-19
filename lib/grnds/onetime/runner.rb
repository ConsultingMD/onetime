require 'grnds/onetime/runner/change_registry'

module Grnds
  module Onetime
    class Runner
      @children = []

      def self.children
        @children
      end

      def self.inherited(obj)
        Grnds::Onetime::Runner.children.push obj
      end

      def run_all
        register_ar_classes_for_changes
        fetch_script_numbers_from_database
        load_scripts_that_need_run

        puts "#{Grnds::Onetime::Runner.children.count} scripts to process"
        puts '~~~~~~~~~~~~~~~~~~~~~'

        Grnds::Onetime::Runner.children.each { |klass| process_one klass }
      rescue => e
        offending_file = e.send(:caller_locations).first.path.split("/").last
        puts "#{offending_file} caused an error: "
        raise e
      end

      def version_number
        # We have to find the actual file where the class is defined which is the reason for
        # the method source location weirdness
        @version_number ||= File.basename(method(:run).source_location.first).scan(/\A(\d{10,})/).first.first
      end

      private def fetch_script_numbers_from_database
        @versions ||= ActiveRecord::Base
                      .connection
                      .exec_query('SELECT version FROM onetime_scripts')
                      .map { |r| [r.fetch('version').to_s, true] }.to_h
      end

      private def load_scripts_that_need_run
        Dir.glob("#{Rails.root}/script/onetime/*.rb")
          .map { |f| File.basename(f) }
          .reject { |f| f.scan(/\A(\d{10,})/).empty? }
          .reject { |f| @versions.has_key?(f.scan(/\A(\d{10,})/).first.first) }
          .each { |f| require File.join(Rails.root, 'script', 'onetime', f) }
      end

      private def register_ar_classes_for_changes
        ActiveRecord::Base.descendants.each do |klass|
          next if klass.name.match(/Audited/)
          klass.class_eval do
            before_save -> (me) { Grnds::Onetime::Runner::ChangeRegistry.notify me }
          end
        end
      end

      private def process_one klass
        ChangeRegistry.flush
        runner = klass.new

        puts ''
        puts "Processing #{klass.name} from #{runner.owner}:"
        puts "#{runner.description}"
        puts ''

        ActiveRecord::Base.transaction do
          if runner.run
            ActiveRecord::Base.connection.execute <<-SQL
              INSERT INTO onetime_scripts (version, owner, description, completed_at, changes)
              VALUES (#{runner.version_number}, "#{runner.owner}", "#{runner.description}", "#{Time.now}", "#{ActiveRecord::Base.sanitize ChangeRegistry.dump}");
            SQL
          else
            puts "#{klass.name} ran without errors, but was not successful"
            if runner.failure_message
              puts "The resulting falure was: #{runner.failure_message}"
            else
              puts "The falure message was not set. Find #{runner.owner} to help investigate"
            end
            fail ActiveRecord::Rollback
          end
        end

        puts ''
        puts "Finished #{klass.name}"
        puts '~~~~~~~~~~~~~~~~~~~~~'
      end
    end
  end
end
