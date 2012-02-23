module Spectrum

  # Describe is the BDD form of a testcase. It organizes a collection of
  # behavior specifications.
  #
  class Describe

    #
    # The parent context in which this describe resides.
    #
    attr :parent

    #
    # The text description of the describe clause.
    #
    attr :label

    #
    #
    #
    attr :tags

    #
    # List of specs and sub-describes.
    #
    attr :specs

    #
    # The before and after hooks.
    #
    attr :hooks

    #
    # Specs to skip based on match criteria.
    #
    attr :skips

    #
    # DSL module for evaluating `describe` blocks.
    #
    attr :scope

    #
    # A test case +target+ is a class or module.
    #
    def initialize(settings={}, &block)
      @parent  = settings[:parent]
      @label   = settings[:label]
      @tags    = settings[:tags]
      #@skips  = settings[:skips]
      #@hooks  = settings[:hooks]

      if @parent
        @hooks = parent.hooks.clone
        @skips = parent.skips.clone
      else
        @hooks = Hooks.new
        @skips = []
      end

      @specs = []

      @scope = Scope.new(self)

      evaluate(&block)
    end

    #
    # Evalute a block of code in the context of the Describe's scope.
    # When finished it iterates over `skips` and marksa any matching
    # specs to be skipped.
    #
    def evaluate(&block)
      @scope.module_eval(&block)

      specs.each do |spec|
        skips.each do |match, reason|
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
      @it_scope ||= It::Scope.new(self)
    end

    #
    #
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
    #
    #
    def type
      'describe'
    end

    #
    #
    #
    def to_s
      label.to_s
    end

    #
    #
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

    # Describe scope is used for defining sepcifications.
    #
    class Scope < World

      #
      # Setup new evaluation scope.
      #
      def initialize(describe)
        @_desc  = describe
        @_hooks = describe.hooks
        @_skips = describe.skips

        if describe.parent
          extend(describe.parent.scope)
        end
      end

      #
      # Create a .
      #
      def describe(label, *tags, &block)
        settings = {
          :parent  => @_desc,
          :hooks   => @_hooks,
          :skips   => @_skips,
          :label   => label,
          :tags    => tags
        }
        describe = Describe.new(settings, &block)

        @_desc.specs << describe

        return describe
      end

      #
      # Create a spec behavior.
      #
      # If tags are given, so must a label.
      #
      def it(label=nil, *tags, &procedure)
        settings = {
          :parent  => @_desc,
          :hooks   => @_hooks,
          :skips   => @_skips,
          :label   => label,
          :tags    => tags
        }
        spec = It.new(settings, &procedure)
       
        @_desc.specs << spec

        spec
      end

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
        #which = :each if which != :all  # temporary
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
        #which = :each if which != :all  # temporary
        @_hooks.add(:after, which, *tags, &procedure)
      end

# TODO: RubyTest, should omit and skip swap meanings?

      # TODO: Rename `omit` ?

      #
      # Mark specs or sub-cases to be skipped.
      #
      # @example
      #   it "should do something" do
      #     ...
      #   end
      #   skip(/something/, "reason for skipping")
      #
      def skip(match, reason=true)
        @_skips << [match, reason || true]
      end

      #
      #
      #
      def let(name, &block)
        define_method(name) do
          __let_cache.fetch(name) {|k| __let_cache[k] = instance_eval(&block) }
          #__let_cache[name] ||= block.call
        end
      end

      #
      #
      #
      def subject(&block)
        define_method(:subject, &block)
      end

    end

  end

end
