$TEST_SUITE ||= []

module Spectroscope

  require 'spectroscope/world'
  require 'spectroscope/hooks'
  require 'spectroscope/example'
  require 'spectroscope/context'

  module DSL
    #
    # Define an example group.
    #
    def describe(topic, *tags, &block)
      settings = {}

      if Class === topic
        settings[:subject] = topic
        settings[:label]   = topic.name
      else
        settings[:label]   = topic
      end

      $TEST_SUITE << Spectroscope::Context.new(settings, &block)
    end

    #
    #
    #
    def shared_examples_for(label, &block)
      Spectroscope.shared_examples[label] = block
    end
  end

  #
  def self.shared_examples
    @shared_examples ||= {}
  end

end

extend Spectroscope::DSL

