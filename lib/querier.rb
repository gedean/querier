require 'active_record'

class Querier
  PARAM_NAME_INDEX = 0
  PARAM_VALUE_INDEX = 1

  @active_record_class = ActiveRecord::Base
  # based on rubocop's tips at: https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/ClassVars
  # solution here: https://www.ruby-lang.org/en/documentation/faq/8/
  class << self
    attr_accessor :active_record_class
  end

  attr_reader :query, :query_template, :query_params

  def initialize(template_query_params = {})
    @active_record_class = self.class.active_record_class || self.class.superclass.active_record_class
    @query_params = template_query_params
    @query = fill_query_params
  end

  def execute
    @active_record_class.connection.execute(@query)
  end

  def select_all
    result = @active_record_class.connection.select_all(@query)

    def result.as_hash
      map(&:symbolize_keys!)
    end

    def result.as_struct
      map { |record| OpenStruct.new(record) }
    end

    result
  end

  private

  def get_param_value(raw_query_param:, quotefy_param: true)
    # where's String#quote when we need it?
    raw_query_param.instance_of?(String) && quotefy_param ? "'#{raw_query_param.to_s}'" : raw_query_param.to_s
  end

  def fill_query_params
    query = @query_template.dup

    @query_params.each_pair do |query_param|
      query_param_name = query_param[PARAM_NAME_INDEX].to_s

      query.gsub!(/\${#{query_param_name}}/,
                  get_param_value(raw_query_param: query_param[PARAM_VALUE_INDEX], 
                                  quotefy_param: true))

      query.gsub!(/\${#{query_param_name}\/no_quote}/,
                  get_param_value(raw_query_param: query_param[PARAM_VALUE_INDEX],
                                  quotefy_param: false))
    end

    query
  end
end
