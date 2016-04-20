namespace :onetime do
  def table_exists?
    ActiveRecord::Base.connection.table_exists? 'onetime_scripts'
  end

  def ensure_table_exists
    Rake::Task['onetime:install'] unless table_exists?
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
  task run_pending_scripts: :environment do
    ensure_table_exists
    runner = Grnds::Onetime::Runner.new
    runner.run_all
  end
end
