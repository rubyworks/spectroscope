module Spectrum

  # Specification advice.
  #
  class Hooks

    ## A brief description of the advice (optional).
    #attr :label

    #
    # New case instance.
    #
    def initialize
      @hooks_all  = {:before=>[], :after=>[]}
      @hooks_each = {:before=>[], :after=>[]}
    end

    #
    def initialize_copy(original)
      original.hooks_all do |tense, hooks|
        hooks_all[tense] = hooks.clone
      end
      original.hooks_each do |tense, hooks|
        hooks_each[tense] = hooks.clone
      end
    end

    #
    def add(tense, range, *tags, &proc)
      case range
      when :all
        raise ArgumentError, "tagged #{tense}-all advice is useless" unless tags.empty?
        @hooks_all[tense]  << Hook.new(tense, range, *tags, &proc)
      when :each
        @hooks_each[tense] << Hook.new(tense, range, *tags, &proc)
      else
        raise ArgumentError, "range must be :all or :each"
      end
    end

    #
    def run(target, tense, range, scope)
      case range
      when :all
        hooks_all[tense].each do |hook|
          scope.instance_eval(&hook)
        end
      when :each
        hooks_each[tense].each do |hook|
          scope.instance_eval(&hook) if hook.match?(target)
        end
      else
        raise ArgumentError, "range must be :all or :each"
      end
    end

  private

    #
    #def validate(tense, scope)
    #  raise ArgumentError unless tense == :before or tense == :after
    #  raise ArgumentError unless scope == :all    or tense == :each
    #end

  protected

    #
    attr :hooks_all

    #
    attr :hooks_each

    # Encapsulates a hook procedure along with it's match tags.
    #
    class Hook

      def initialize(tense, scope, *tags, &proc)
        @tense = tense
        @scope = scope
        @tags  = tags
        @proc  = proc
      end

      #
      # Check for mathcing labels or tags for each advice.
      #
      def match?(it)
        return true if @tags.empty?

        @tags.any? do |t|
          it.match?(t)
        end
      end

      #
      def to_proc
        @proc
      end

    end

  end

end
