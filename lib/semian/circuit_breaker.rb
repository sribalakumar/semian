module Semian
  class CircuitBreaker #:nodoc:
    extend Forwardable

    def_delegators :@state, :closed?, :open?, :half_open?

    attr_reader :name

    def initialize(name, exceptions:, success_threshold:, error_threshold:, error_timeout:, implementation:)
      @name = name.to_sym
      @success_count_threshold = success_threshold
      @error_count_threshold = error_threshold
      @error_timeout = error_timeout
      @exceptions = exceptions

      @errors = implementation::Error.new
      @successes = implementation::Integer.new
      @state = implementation::State.new
    end

    def acquire
      half_open if open? && error_timeout_expired?

      raise OpenCircuitError unless request_allowed?
      # unless request_allowed?
      #   Semian.logger.info("Throwing Open Circuit Error")
      #   #instrumentable lib won't work, consider it later.
      # end

      result = nil
      begin
        result = yield
      rescue *@exceptions => error
        mark_failed(error)
        raise error
      else
        mark_success
      end
      result
    end

    def request_allowed?
      closed? ||
        half_open? ||
        # The circuit breaker is officially open, but it will transition to half-open on the next attempt.
        (open? && error_timeout_expired?)
    end

    def mark_failed(_error)
      Rails.logger.info("****** Marking Resource Failure in Semian ******")
      Rails.logger.info("#{_error.class.name} : #{_error.message}")
      @errors.increment
      set_last_error_time
      if closed?
        open if error_threshold_reached?
      elsif half_open?
        open
      end
    end

    def mark_success
      @errors.reset
      return unless half_open?
      @successes.increment
      close if success_threshold_reached?
    end

    def reset
      @errors.reset
      @successes.reset
      close
    end

    def destroy
      @errors.destroy
      @successes.destroy
      @state.destroy
    end

    private

    def close
      log_state_transition(:closed)
      @state.close
      @errors.reset
      @successes.reset # Bug fix for log_state_transition.
    end

    def open
      log_state_transition(:open)
      @state.open
      #@errors.reset # Not needed because the next state it going to be half_open and reset there.
    end

    def half_open
      log_state_transition(:half_open)
      @state.half_open
      @errors.reset
      @successes.reset
    end

    def success_threshold_reached?
      @successes.value >= @success_count_threshold
    end

    def error_threshold_reached?
      @errors.value >= @error_count_threshold
    end

    def error_timeout_expired?
      return false unless @errors.last_error_time
      Time.at(@errors.last_error_time) + @error_timeout < Time.now
    end

    def set_last_error_time(time: Time.now)
      @errors.last_error_at(time.to_i)
    end

    def log_state_transition(new_state)
      return if @state.nil? || new_state == @state.value

      str = "[#{self.class.name}] State transition from #{@state.value} to #{new_state}."
      str << " success_count=#{@successes.value} error_count=#{@errors.value}"
      str << " success_count_threshold=#{@success_count_threshold} error_count_threshold=#{@error_count_threshold}"
      str << " error_timeout=#{@error_timeout} error_last_at=\"#{@errors.last_error_time ? Time.at(@errors.last_error_time) : ''}\""
      Semian.logger.info(str)
    end
  end
end
