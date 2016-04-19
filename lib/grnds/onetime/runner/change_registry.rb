module Grnds
  module Onetime
    class Runner
      module ChangeRegistry
        # This is very, very not thread-safe. Be warned.
        # It is challenging to observe AR changes on a global level but only capture the changes
        # we want within a limited scope. Therefore the easiest way of doing this right now
        # is globally register all AR classes to a single registry, and then flush
        # all changes as needed.
        #
        # Another possible way is to tell the registry to capture changes within a block,
        # like `ChangeRegistry.start_listening do` but ignore any changes outside of the block

        # {
          # Class => {
            # changes_hash => [id, of, objects, that, match, change]
          # }
        # }
        @changes = {}

        def self.notify(record)
          hashref = @changes[record.class] ||= {}
          arrayref = hashref[record.changes] ||= []
          arrayref.push record.id
        end

        def self.dump
          buffer = []
          @changes.each do |klass_key, changes_groups|
            changes_groups.each do |change, ids|
              buffer.push "#{klass_key.name}[#{ids.join(', ')}]{#{reformat_change(change)}}"
            end
          end
          buffer.join("\n")
        end

        def self.flush
          @changes = {}
        end

        def self.reformat_change(change_hash)
          change_hash
        end
      end
    end
  end
end
