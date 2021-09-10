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

  attr_reader :query_execution_count, :query_template, :query_params

  def initialize(template_query_params = {})
    @active_record_class = self.class.active_record_class || self.class.superclass.active_record_class
    @query_execution_count = 0
    @query_params = template_query_params
  end

  def execute
    @query_execution_count += 1
    @execution_cached_result = @active_record_class.connection.select_all(fill_query_params(query_template: @query_template,
                                                                                         query_params: @query_params)).map(&:symbolize_keys!)
  end

  def cached_result(format: :hash)
    raise 'query not executed yet' if @query_execution_count.eql?(0)

    case format
    when :hash
      @execution_cached_result
    when :open_struct
      hash_to_open_struct(dataset: @execution_cached_result)
    else
      raise 'invalid value type'
    end
  end

  def structured_results
    hash_to_open_struct(dataset: execute)
  end

  def to_sql
    fill_query_params(query_template: @query_template, query_params: @query_params)
  end

  def to_file
    file_name = "querier #{Time.now.strftime '[%d-%m-%Y]-[%Hh %Mm %Ss]'}.sql"
    File.write "tmp/#{file_name}", to_sql
  end

  def field_group_and_count(field_name:, sort_element_index: nil, reverse_sort: true)
    count_result = cached_result(format: :open_struct).group_by(&field_name).map { |k, v| [k, v.count] }

    unless sort_element_index.nil?
      count_result = count_result.sort_by { |el| el[sort_element_index] }
      count_result.reverse! if reverse_sort.eql? true
    end

    count_result
  end

  private

  def hash_to_open_struct(dataset:)
    dataset.map { |record| OpenStruct.new(record.symbolize_keys!) }
  end

  def get_param_value(raw_query_param:, quotefy_param: true)
    # where's String#quote when we need it?
    raw_query_param.instance_of?(String) && quotefy_param ? "'#{raw_query_param.to_s}'" : raw_query_param.to_s
  end

  def fill_query_params(query_template:, query_params:)
    query = query_template

    query_params.each_pair do |query_param|
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
