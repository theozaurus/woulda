module Woulda
  module ShouldRaise
    module Macros
      # Make sure a block raises an exception.
      # Call with optional arguments :instance_of/:kind_of and :message
      # If :instance_of or :kind_of is specified, assert on the given type. 
      #   Otherwise only assert that an exception is raised.
      #   Note: The shorthand should_raise(LoadError) is equivalent to should_raise(:instance_of => LoadError)
      # If :message is specified, will assert that exception.message =~ :message.
      #
      # Examples:
      #   should_raise {a block}
      #   should_raise(LoadError) {a block}
      #   should_raise(:instance_of => LoadError) {a block}
      #   should_raise(:kind_of => LoadError) {a block}
      #   should_raise(:message => "no such file to load") {a block}
      #   should_raise(:message => /load/) {a block}
      #   should_raise(LoadError, :message => /load/) {a block}
      #   should_raise(:kind_of => LoadError, :message => /load/) {a block}
      #   should_raise(:instance_of => LoadError, :message => /load/) {a block}
      def should_raise(*args, &block)
        opts = args.last.is_a?(Hash) ? args.pop : {}

        if args.first.is_a?(Class)
          type  = args.first
          exact = true
        else
          type  = opts[:instance_of] || opts[:kind_of]
          exact = !!opts[:instance_of]
        end
        message = opts[:message]

        # Make sure we don't have a false sense of security and bork if incorrect options are supplied.
        [:message, :instance_of, :kind_of].each { |acceptable_arg| opts.delete(acceptable_arg) }
        raise ArgumentError, "Unknown parameter(s): #{opts.keys.inspect}. Only :message, :instance_of and :kind_of are supported." if opts.size > 0

        context "block #{block.inspect}" do # To avoid dupes
          if type

            should "raise an exception of type #{type.inspect}" do
              begin
                yield
              rescue Exception => ex
                @raised_exception = ex
              end
              if exact
                assert_instance_of type, @raised_exception
              else
                assert_kind_of type, @raised_exception
              end
            end

          else

            should "raise an exception" do
              has_raised = false
              begin
                yield
              rescue Exception => ex
                has_raised = true
              end
              assert has_raised, "The block was expected to raise an exception, but didn't"
            end

          end
        end

        if message
          context "raising an exception" do
            setup do
              begin
                yield
              rescue Exception => ex
                @raised_exception = ex
              end
            end

            should "contain a message that matches #{message.inspect}" do
              assert_match message, @raised_exception.message
            end
          end
        end
      end
    end
  end
end