# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :environment, ENV['RAILS_ENV']
set :output, {:error => 'log/whenever_error.log', :standard => 'log/whenever.log'}

case environment
  when 'production'
    # every :monday, at: '8:25pm' do # Use any day of the week or :weekend, :weekday
    #   rake "data:truncate_omop_clinical_data_tables"
    # end

    # every :monday, at: '8:25pm' do # Use any day of the week or :weekend, :weekday
    #   rake "data:drop_omop_indexes"
    # end
    #

    # every :sunday, at: '9:05pm' do # Use any day of the week or :weekend, :weekday
    #   rake "data:load_omop_clinical_tables"
    # end

    # every :monday, at: '5:25am' do # Use any day of the week or :weekend, :weekday
    #   rake "data:compile_omop_indexes"
    # end

    # every :tuesday, at: '7:15am' do # Use any day of the week or :weekend, :weekday
    #   rake "data:create_note_stable_identifier_entires"
    # end

    every :sunday, at: '10:35pm' do # Use any day of the week or :weekend, :weekday
      rake "suggestor:do"
    end
  when 'staging'
end