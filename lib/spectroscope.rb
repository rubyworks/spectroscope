$TEST_SUITE ||= []

module Spectroscope

  require 'spectroscope/world'
  require 'spectroscope/hooks'
  require 'spectroscope/example'
  require 'spectroscope/context'

  # The DSL module extends the toplevel.
  #
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
  # Store for shared examples.
  #
  # @return [Hash] shared examples
  #
  def self.shared_examples
    @shared_examples ||= {}
  end

  #
  # Access to project metadata.
  #
  # @return [Hash] metadata
  #
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load_file(File.dirname(__FILE__), '/spectrascope.yml')
    )
  end

  #
  # If constant is missing, check for it in project metadata.
  #
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end

end

extend Spectroscope::DSL
