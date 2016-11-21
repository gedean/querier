class Querier
  PARAM_NAME_INDEX = 0
  PARAM_VALUE_INDEX = 1
  attr_reader :query_template, :query_params
  
  def initialize **template_query_params
    @query_params = template_query_params.dup
  end

  def execute
    ActiveRecord::Base.connection.select_all build_query(query_template: @query_template, query_params: @query_params)
  end   

  def structured_results
    query_results = self.execute
    structured_results = [] 
    query_results.each {|query_result| structured_results << OpenStruct.new(query_result.symbolize_keys!)}
    structured_results
  end  

  def to_sanitized_sql
    to_sql.gsub(/\n/, ' ').gsub(/\t/, ' ')
  end

  def to_sql
    build_query(query_template: @query_template, query_params: @query_params)
  end

  private
  
  def build_query query_template:, query_params:
    query = query_template.dup
    
    query_params.each do |query_param|
      query_param_name = query_param[PARAM_NAME_INDEX].to_s
      query_param_value = query_param[PARAM_VALUE_INDEX].class.eql?(String) ? "'#{query_param[PARAM_VALUE_INDEX].to_s}'" : query_param[PARAM_VALUE_INDEX].to_s

      query.gsub! /{\?#{query_param_name}}/, query_param_value
    end

    query
  end
end