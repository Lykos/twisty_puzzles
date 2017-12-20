require 'results_persistence'

class ResultsModel

  def initialize(mode)
    @mode = mode
    @result_persistence = ResultsPersistence.new
    @results = @result_persistence.load_results
    @results_listeners = [@result_persistence]
  end

  attr_reader :mode

  def results
    @mode_results ||= begin
                        unless @results.has_key?(@mode)
                          @results[@mode] = []
                        end
                        @results[@mode]
                      end
  end

  def add_result_listener(listener)
    @result_listeners.push(listener)
  end

  def record_result(result)
    results.unshift(result)
    @results_listeners.each { |l| l.record_result(@mode, result) }
  end

  def delete_after_time(timestamp)
    results.delete_if { |r| r.timestamp > timestamp }
    @results_listeners.each { |l| l.delete_after_time(@mode, timestamp) }
  end
  
  def words_for_input(input)
    results.select { |r| r.input == input }.collect { |r| r.word }.uniq
  end

  def inputs_for_word(word)
    results.select { |r| r.word == word }.collect { |r| r.input }.uniq
  end

  def replace_word(input, word)
    results.collect! { |r| if r.input == input then r.with_word(word) else r end }
    @results_listeners.each { |l| l.replace_word(@mode, input, word) }
  end

end
