class Querier
  PARAM_NAME_INDEX = 0
  PARAM_VALUE_INDEX = 1

  attr_reader :query_template, :query_params
  
  def initialize **template_query_params
    @query_params = template_query_params.dup
  end

  def execute
    ActiveRecord::Base.connection.select_all fill_query_params(query_template: @query_template, query_params: @query_params)
  end   

  def structured_results
    query_results = self.execute
    structured_results = [] 
    query_results.each {|query_result| structured_results << OpenStruct.new(query_result.symbolize_keys!)}
    structured_results
  end  

  def to_sql
    fill_query_params(query_template: @query_template, query_params: @query_params)
  end

  def to_file
    file_name = "querier #{Time.now.strftime "[%d-%m-%Y]-[%Hh %Mm %Ss]"}.sql"
    File.open("tmp/#{file_name}", 'w') {|f| f << self.to_sql}
  end

  def field_group_and_count field_name:, sort_element_index: nil, reverse_sort: true
    count_result = @cached_results.group_by(&field_name).map {|k, v| [k, v.count]}
    
    unless sort_element_index.nil?
      count_result = count_result.sort_by {|el| el[sort_element_index]}
      count_result.reverse! if reverse_sort.eql? true
    end
    
    count_result
  end    

  private
  
  def get_param_value raw_query_param
    # where's String#quote when we need it?
    raw_query_param.class.eql?(String) ? "'#{raw_query_param.to_s}'" : raw_query_param.to_s
  end

  def fill_query_params query_template:, query_params:
    query = query_template.dup
    
    query_params.each do |query_param|
      query_param_name = query_param[PARAM_NAME_INDEX].to_s
      query_param_value = get_param_value(query_param[PARAM_VALUE_INDEX])

      query.gsub! /{\?#{query_param_name}}/, query_param_value
    end

    query
  end
end