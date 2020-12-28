class Querier
  PARAM_NAME_INDEX = 0
  PARAM_VALUE_INDEX = 1

  attr_reader :query_execution_count, :query_template, :query_params
  
  def initialize **template_query_params
    @query_execution_count = 0
    @query_params = template_query_params.dup
  end

  def execute
    @query_execution_count += 1
    @execution_cached_result = ActiveRecord::Base.connection.select_all(fill_query_params(query_template: @query_template, query_params: @query_params))
    @execution_cached_result = execution_cached_result.map! { |record| record.symbolize_keys! }
  end   

  def cached_result format: :hash
    raise 'query not executed yet' if @query_execution_count.eql?(0)
    
    case format.to_s
      when 'hash' 
        @execution_cached_result
      when 'open_struct'
          hash_to_open_struct(dataset: @execution_cached_result)
      else
          raise 'invalid value type'
    end
  end
  
  def structured_results
    hash_to_open_struct dataset: self.execute
  end  

  def to_sql
    fill_query_params(query_template: @query_template, query_params: @query_params)
  end

  def to_file
    file_name = "querier #{Time.now.strftime "[%d-%m-%Y]-[%Hh %Mm %Ss]"}.sql"
    File.open("tmp/#{file_name}", 'w') {|f| f << self.to_sql}
  end

  def field_group_and_count field_name:, sort_element_index: nil, reverse_sort: true
    count_result = self.cached_results(format: :open_struct).group_by(&field_name).map {|k, v| [k, v.count]}
    
    unless sort_element_index.nil?
      count_result = count_result.sort_by {|el| el[sort_element_index]}
      count_result.reverse! if reverse_sort.eql? true
    end
    
    count_result
  end    

  private

  def hash_to_open_struct dataset:
    dataset.map {|record| OpenStruct.new(record.symbolize_keys!)}
  end  
  
  def get_param_value raw_query_param:, quotefy_param: true
    # where's String#quote when we need it?
    raw_query_param.class.eql?(String) && quotefy_param ? "'#{raw_query_param.to_s}'" : raw_query_param.to_s
  end

  def fill_query_params query_template:, query_params:
    query = query_template.dup
    
    query_params.each do |query_param|
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