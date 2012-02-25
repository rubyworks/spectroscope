module Spectra

  # This is the BDD form of a test case. It encapsulates a collection
  # of examples.
  #
  # This is the `describe` in your specs.
  #
  class Context

    #
    # The parent context in which this describe resides.
    #
    attr :parent

    #
    # A description of the describe clause.
    #
    attr :label

    #
    # A target class, if any.
    #
    attr :subject

    #
    # Array and/or metadata Hash of tags.
    #
    attr :tags

    #
    # List of examples and sub-specifications.
    #
    attr :specs

    #
    # The before and after hooks.
    #
    attr :hooks

    #
    # Skip critera.
    #
    # @return [Array<String,Proc>]
    #
    attr :skips

    #
    # Omit criteria.
    #
    # @return [Array<String,Proc>]
    #
    attr :omits

    #
    # DSL module for evaluating `describe` blocks.
    #
    attr :scope

    #
    # A test case +target+ is a class or module.
    #
    def initialize(settings={}, &block)
      @parent  = settings[:parent]
      @subject = settings[:subject]
      @label   = settings[:label]
      @tags    = settings[:tags]
      #@skips  = settings[:skips]
      #@hooks  = settings[:hooks]

      if @parent
        @hooks = parent.hooks.clone
        @skips = parent.skips.clone
        @omits = parent.omits.clone
      else
        @hooks = Hooks.new
        @skips = []
        @omits = []
      end

      @specs = []

      @scope = Scope.new(self)

      evaluate(&block)
    end

    #
    # Evalute a block of code in the context of the Context's scope.
    # When finished it iterates over `omits` and `skips`, removing and
    # marks examples to be skipped respectively.
    #
    def evaluate(&block)
      @scope.module_eval(&block)

      specs.delete_if do |spec|
        omits.any?{ |reason, block| block.call(spec) }
      end

      specs.each do |spec|
        skips.each do |reason, block|
          if spec.match?(match)
            spec.skip = reason
          end
        end
      end
    end

    #
    # Shared runtime scope for specs.
    #
    def it_scope
      @it_scope ||= Example::Scope.new(self)
    end

    #
    # Add `it` or sub-`describe` to group.
    #
    def <<(spec)
      @specs << spec
    end

    #
    # Iterate over each test and subcase.
    #
    def each(&block)
      specs.each(&block)
    end

    #
    # Run before-all and after-all advice around yeilding
    # to test runss.
    #
    def call
      hooks.run(self, :before, :all, it_scope)
      yield
      hooks.run(self, :after,  :all, it_scope)
    end

    #
    # Number of specs plus subcases.
    #
    def size
      specs.size
    end

    #
    # Ruby Test supports `type` to describe the nature of
    # the underlying test system.
    #
    def type
      'describe'
    end

    alias :inspect :to_s

    #
    # Returns the subject/label as string.
    #
    def to_s
      label.to_s
    end

    #
    # Skip this group?
    #
    def skip?
      @skip
    end

    #
    #
    #
    def skip=(reason)
      @skip = reason
    end

    #
    # Run test in the parent of this case.
    #
    # @param [TestProc] test
    #   The test unit to run.
    #
    def run(test, &block)
      #hooks[:before].each do |match, block|
      #  next if Symbol == match
      #  if test.match?(match)
      #    scope.instance_exec(test, &block) #block.call(unit)
      #  end
      #end

      block.call

      #hooks[:after].each do |match, block|
      #  next if Symbol == match
      #  if test.match?(match)
      #    scope.instance_exec(test, &block) #block.call(unit)
      #  end
      #end
    end

    # Context scope is used for defining sepcifications.
    #
    class Scope < World

      #
      # Setup new evaluation scope.
      #
      def initialize(group)
        @_group = group
        @_hooks = group.hooks
        @_skips = group.skips
        @_omits = group.omits

        if group.parent
          include(group.parent.scope)
        end
      end

      #
      # Create a new sub-specification.
      #
      def describe(topic, *tags, &block)
        settings = {}
        settings[:parent]  = @_group
        settings[:subject] = @_group.subject
        settings[:tags]    = tags

        if Class === topic
          settings[:subject] = topic
          settings[:label]   = topic.name
        else
          settings[:label]   = topic
        end

        group = Context.new(settings, &block)

        @_group.specs << group

        return group
      end

      alias_method :context, :describe

      #
      # Create an example behavior.
      #
      # If tags or keys are given, so must a label.
      #
      def it(label=nil, *tags, &procedure)
        keys = (Hash===tags ? tags.pop : {})

        settings = {
          :parent => @_group,
          :hooks  => @_hooks,
          :skips  => @_skips,
          :omits  => @_omits,
          :topic  => @_topic,
          :label  => label,
          :tags   => tags,
          :keys   => keys
        }

        spec = Example.new(settings, &procedure)
       
        @_group.specs << spec

        spec
      end

      #
      #
      #
      alias_method :example, :it

      #
      # Define before procedure.
      #
      # @example
      #   describe '#puts' do
      #     it "gives standard output" do
      #       puts "Hello"
      #     end
      #
      #     before do
      #       $stdout = StringIO.new
      #     end
      #
      #     after do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Symbol] which
      #   Must be either `:all` or `:each`, the later being the default.
      #
      # @param [Array<Symbol>] tags
      #   List of match critera that must be matched
      #   against tags to trigger the before procedure.
      #
      def before(which=:each, *tags, &procedure)
        @_hooks.add(:before, which, *tags, &procedure)
      end

      #
      # Define a _complex_ after procedure. The #before method allows
      # before procedures to be defined that are triggered by a match
      # against the unit's target method name or _aspect_ description.
      # This allows groups of specs to be defined that share special
      # teardown code.
      #
      # @example
      #   describe '#puts' do
      #     it "gives standard output (@stdout)" do
      #       puts "Hello"
      #     end
      #
      #     before do
      #       $stdout = StringIO.new
      #     end
      #
      #     after do
      #       $stdout = STDOUT
      #     end
      #   end
      #
      # @param [Symbol] which
      #   Must be either `:all` or `:each`, the later being the default.
      #
      # @param [Array<Symbol>] tags
      #   List of match critera that must be matched
      #   to trigger the after procedure.
      #
      def after(which=:each, *tags, &procedure)
        @_hooks.add(:after, which, *tags, &procedure)
      end

      #
      # Mark specs or sub-cases to be skipped.
      #
      # @example
      #   it "should do something" do
      #     ...
      #   end
      #   skip(/something/, "reason for skipping") if jruby?
      #
      def skip(reason, &block)
        @_skips << [reason, block]
      end

      #
      # Mark specs or sub-cases to be omitted. Omitting a test is different
      # from skipping, in tha the later is still sent up to the test harness,
      # where as omitted tests never get added at all.
      #
      # @example
      #   it "should do something" do
      #     ...
      #   end
      #   omit(/something/) if jruby?
      #
      def omit(reason=true, &block)
        @_omits << [reason, block]
      end

      #
      #
      #
      def let(name, &block)
        define_method(name) do
          #_let[name] ||= block.call
          @_let.fetch(name){ |k| @_let[k] = instance_eval(&block) }
        end
      end

      #
      #
      #
      def let!(name, &block)
        let(name, &block)
        before { __send__(name) }
      end

      #
      #
      #
      def subject(topic=nil, &block)
        @_topic = topic
        define_method(:subject, &block)
      end

      #
      # Subject-oriented example.
      #
      # RSpec itself wraps this whole thing in another `describe(invocation)`
      # clause, but that seems completely extraneous.
      #
      def its(invocation, &block)
        case invocation
        when Symbol
          it(invocation.to_s) do
            subject.__send__(invocation).instance_eval(&block)
          end
        else
          it(invocation.to_s) do
            #eval("subject.#{invocation}", binding).instance_eval(&block)
            calls = invocation.to_s.split('.')
            calls.inject(subject){ |s,m| s.__send__(invocation) }.instance_eval(&block)
          end
        end
      end

      #
      #
      #
      #def shared_examples_for(label, &block)
      #  @_shared_examples[label] = block
      #end

      #
      #
      #
      def it_behaves_like(label)
        proc = Spectra.shared_examples[label]
        module_eval(&proc)
      end

    end

  end

end
