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

  def exec_query
    decorate_dataset_format(@active_record_class.connection.exec_query(@query))
  end

  def select_all
    decorate_dataset_format(@active_record_class.connection.select_all(@query))
  end

  def select_one
    @active_record_class.connection.select_one(@query)
  end

  def select_sole
    @active_record_class.connection.select_sole(@query)
  end

  def select_values
    @active_record_class.connection.select_values(@query)
  end

  def select_rows
    @active_record_class.connection.select_rows(@query)
  end

  def select_value
    @active_record_class.connection.select_value(@query)
  end

  private

  def decorate_dataset_format(dataset)
    def dataset.as_hash
      map(&:symbolize_keys)
    end

    def dataset.as_struct
      map { |record| OpenStruct.new(record) }
    end

    dataset
  end

  def get_param_value(raw_query_param:, quotefy_param: true)
    if raw_query_param.instance_of?(String) && quotefy_param
      @active_record_class.connection.quote(raw_query_param.to_s)
    else
      raw_query_param.to_s
    end
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
