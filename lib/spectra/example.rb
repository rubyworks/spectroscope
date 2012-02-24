module Spectra

  # Example behavior.
  #
  # This is the `it` in your specs.
  #
  class Example

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
    # be a list of Symbols.
    #
    attr :tags

    #
    # A map of Symbol => Object, which works like `tags`, but allows
    # got key-value relationship, rather than just symbolic tags.
    #
    attr :keys

    #
    # In RSpec data keys are called metadata.
    #
    alias_method :metadata, :keys

    #
    # Test procedure, in which test assertions should be made.
    #
    attr :procedure

    # The before and after advice from the parent.
    #def hooks
    #  parent.hooks
    #end

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
    #
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
    #
    #
    def to_proc
      lambda{ call }
    end

    #
    # If +match+ is a Regexp or String, match against label.
    # If +match+ is a Symbol, match against tags.
    # If +match+ is a Hash, match against keys.
    #
    def match?(match)
      case match
      when Regexp, String
        match === label
      when Hash
        match.any?{ |k,m| m === keys[k] }
      else
        tags.include(match.to_sym)
      end
    end

    #
    # Execute spec.
    #
    def call
      parent.run(self) do
        hooks.run(self, :before, :each, scope) #if hooks
        scope.instance_exec(&procedure)  # TODO: can it take any argument(s) ?
        hooks.run(self, :after,  :each, scope) #if hooks
      end
    end


    # It::Scope is used by Describe to create a shared scope for running
    # `it` behavior specifications.
    #
    class Scope < World

      #
      # @group [Describe]
      #
      def initialize(group)
        @_group = group
        extend group.scope
        #include group.scope
        #extend self
        @_let ||= {}
      end

      #
      # @raise [NotImplementedError] Spec is a "todo".
      #
      def pending(message=nil)
        raise NotImplementedError.new(message)
      end

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

      # Handle implicit subject.
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
