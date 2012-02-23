module Spectrum

  # Behavior specification.
  #
  class It

    # Defines a specification procedure.
    #
    def initialize(options={}, &procedure)
      @parent = options[:parent]
      @hooks  = options[:hooks]
      @label  = options[:label]
      @skip   = options[:skip]
      @tags   = options[:tags]

      @procedure = procedure || lambda{ raise NotImplementedError } # pending

      @tested = false
    end

  public

    #
    # The parent testcase to which this test belongs.
    #
    attr :parent

    #
    #
    #
    attr :hooks

    #
    # Description of test.
    #
    attr :label

    #
    #
    #
    attr :tags

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

    ##
    ## Ruby Test looks for `topic` as the desciption of a test's setup.
    ##
    #def topic
    #  @hooks.to_s
    #end

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
    # If +match+ is a Hash, match against metadata tags.
    #
    def match?(match)
      case match
      when Regexp, String
        match === label
      when Hash
        Hash === tags.last && (
          match.any?{ |k,v| tags.last[k] == v }
        )
      else
        tags.include?(match)
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
      #
      #
      def initialize(describe)
        extend describe.scope
        #extend describe.it_scope
      end

      #
      # @raise [NotImplementedError] Spec is a "todo".
      #
      def pending(message=nil)
        raise NotImplementedError.new(message)
      end

      #
      #
      #
      def __let_cache
        @__let_cache ||= {}
      end

    end

  end

end
