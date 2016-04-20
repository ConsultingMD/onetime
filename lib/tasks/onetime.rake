namespace :onetime do
  def table_exists?
    ActiveRecord::Base.connection.table_exists? 'onetime_scripts'
  end

  desc 'Checks if the required table exists'
  task check_table_exists: :environment  do
    if table_exists?
      puts "The table onetime_scripts exists"
    else
      raise "The table onetime_scripts doesn't exist\nTo create the table run 'rake onetime:install'\n\n"
    end
  end

  desc 'Creates the table needed for grnds-onetime to track the scripts that have been run'
  task install: :environment do
    raise 'Table onetime_scripts already exists' if table_exists?

    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TABLE `onetime_scripts` (
        version varchar(255),
        owner varchar(255),
        description text,
        completed_at datetime,
        changes text,
        KEY `index_onetime_scripts_on_version` (`version`)
      )
    SQL
    Rake::Task['db:_dump'].invoke
  end

  desc 'Run all pending onetime scripts'
  task run_pending_scripts: :check_table_exists  do
    runner = Grnds::Onetime::Runner.new
    runner.run_all
  end
end
