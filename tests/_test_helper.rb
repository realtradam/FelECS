require 'simplecov'
require 'simplecov_small_badge'

# SimpleCovSmallBadge fix
SimpleCovSmallBadge::Formatter.class_eval do
  private
  def state(covered_percent)
    if SimpleCov.minimum_coverage[:line]&.positive?
      if covered_percent >= SimpleCov.minimum_coverage[:line]
        'good'
      else
        'bad'
      end
    else
      'unknown'
    end
  end
end

SimpleCov.start do
  SimpleCov.add_filter 'tests'
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCovSmallBadge::Formatter
  ])
end

require 'minitest/autorun'
