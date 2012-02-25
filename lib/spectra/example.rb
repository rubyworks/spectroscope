module Spectra

  # Example behavior.
  #
  # This is the `it` in your specs.
  #
  class Example

    #
    # Defines a specification procedure.
    #
    def initialize(options={}, &procedure)
      @parent = options[:parent]
      @label  = options[:label]
      @hooks  = options[:hooks]
      @skip   = options[:skip]
      @tags   = options[:tags]
      @keys   = options[:keys]
      @topic  = options[:topic]

      @procedure = procedure || lambda{ raise NotImplementedError } # pending

      @tested = false
    end

  public

    #
    # The parent testcase to which this test belongs.
    #
    attr :parent

    #
    # Before and after advice.
    #
    attr :hooks

    #
    # Description of example.
    #
    attr :label

    #
    # List of identifying tags attached to example. These should
    # be a list of Symbols, with an optional Symbol=>Object tail element.
    #
    attr :tags

    #
    # A map of Symbol => Object, which is taken from the end of `tags`.
    # Unlike tags, keys allow key-value relationships, rather than just
    # symbolic names.
    #
    def keys
      Hash === tags.last ? tags.last : {}
    end

    #
    # In RSpec data keys are called metadata.
    #
    alias_method :metadata, :keys

    #
    # Test procedure, in which test assertions should be made.
    #
    attr :procedure

    #
    # RubyTest supports `type` to describe the way in which the underlying
    # framework represents tests.
    #
    def type
      'it'
    end

    #
    # Skip this spec?
    #
    def skip?
      @skip
    end

    #
    # Set +true+ to skip, or String to skip with reason.
    #
    def skip=(reason)
      @skip = reason
    end

    #
    #
    #
    def tested?
      @tested
    end

    #
    #
    #
    def tested=(boolean)
      @tested = !!boolean
    end

    #
    # Return label string.
    #
    # @return [String]
    #
    def to_s
      label.to_s
    end

    #
    # Ruby Test looks for `topic` as the desciption of the subject.
    #
    def topic
      @topic.to_s
    end

    #
    # The shared It::Scope from the parent.
    #
    def scope
      @scope ||= Scope.new(parent)
    end

    #
    #def arguments
    #  @arguments
    #end

    #
    #def arguments=(args)
    #  @arguments = args
    #end

    #
    # If +match+ is a Regexp or String, match against label.
    # If +match+ is a Hash, match against keys.
    # If +match+ is a Symbol, match against tags.
    #
    def match?(match)
      case match
      when Regexp, String
        match === label
      when Hash
        match.any?{ |k,m| m === keys[k] }
      else
        tags.include?(match.to_sym)
      end
    end

    #
    # Execute example.
    #
    def call
      parent.run(self) do
        hooks.run(self, :before, :each, scope) #if hooks
        scope.instance_exec(&procedure)  # TODO: can it take any argument(s) ?
        hooks.run(self, :after,  :each, scope) #if hooks
      end
    end

    #
    # Example can be converted to a Proc object.
    #
    # @return [Proc]
    #
    def to_proc
      lambda{ call }
    end


    # Example::Scope is used by Context to create a shared scope
    # for running examples.
    #
    class Scope < World

      #
      # @param [Context] group
      #
      def initialize(group)
        @_group = group
        extend group.scope
        #include group.scope
        #extend self
        @_let ||= {}
      end

      #
      # @raise [NotImplementedError] Example is a "todo".
      #
      def pending(message=nil)
        raise NotImplementedError.new(message)
      end

      #
      #
      #
      def subject
        @_subject ||= (
          if defined?(super)
            super || described_class.new
          else
            described_class.new
          end
        )
      end

    private

      #
      # Handle implicit subject.
      #
      def method_missing(s, *a, &b)
        subject.__send__(s, *a, &b)  # public_send
      end

      #if method_defined?(:should)
      #  # Handle implicit subject on should.
      #  # @todo Same for method_missing ?
      #  def should(*a,&b)
      #    subject.should(*a,&b)
      #  end
      #end

      #
      # @todo Maybe deprecate. It seems silly.
      #
      def described_class
        case @_group.subject
        when Class
          @_group.subject
        else
          raise NoMethodError, "undefined method `described_class` for #{self}"
        end
      end

    end

  end

end
