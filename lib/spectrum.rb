$TEST_SUITE ||= []

module Spectrum

  require 'spectrum/world'
  require 'spectrum/it'
  require 'spectrum/hooks'
  require 'spectrum/describe'

  module DSL
    #
    # Define a general test case.
    #
    def describe(label, &block)
      $TEST_SUITE << Spectrum::Describe.new(:label=>label, &block)
    end
  end

end

extend Spectrum::DSL

