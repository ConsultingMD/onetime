namespace :script do
  desc 'Run all pending onetime scripts'
  task run_pending_onetime: :environment  do
    runner = Grnds::Onetime::Runner.new
    runner.run_all
  end
end
