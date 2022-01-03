# frozen_string_literal: true

require_relative 'env'

class ReportCoverage
  class << self
    def format
      puts
      puts 'Formatting Coverage...'
      puts `./codeclimate/test-reporter-latest-linux-amd64 format-coverage -t simplecov`
    end

    def upload
      puts `./codeclimate/test-reporter-latest-linux-amd64 upload-coverage --id #{ENV['CC_TEST_REPORTER_ID']}`
    end
  end
end
