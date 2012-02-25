$TEST_SUITE ||= []

module Spectra

  require 'spectra/world'
  require 'spectra/hooks'
  require 'spectra/example'
  require 'spectra/context'

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

      $TEST_SUITE << Spectra::Context.new(settings, &block)
    end

    #
    #
    #
    def shared_examples_for(label, &block)
      Spectra.shared_examples[label] = block
    end
  end

  #
  def self.shared_examples
    @shared_examples ||= {}
  end

end

extend Spectra::DSL
