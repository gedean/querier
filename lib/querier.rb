require 'active_record'
require 'ostruct'

module QuerierDatasetExtensions
  def as_hash = map(&:symbolize_keys)
  def as_struct = map { OpenStruct.new(it) }
  def pluck(*columns) = map { |row| columns.one? ? row[columns.first.to_s] : columns.map { row[it.to_s] } }
  def first_value = first&.values&.first
end

class Querier
  class QueryError < StandardError; end
  
  @active_record_class = ActiveRecord::Base
  
  class << self
    attr_accessor :active_record_class
    
    def query_template(template = nil)
      @query_template = template if template
      @query_template
    end
    
    def param(*names)
      @param_names = names
      names.each do |name|
        define_method(name) do |value|
          @query_params[name] = value
          self
        end
      end
    end
    
    def param_names
      @param_names || []
    end
  end

  attr_reader :query, :query_template, :query_params

  def initialize(template_query_params = {})
    @active_record_class = self.class.active_record_class || self.class.superclass.active_record_class
    @query_params = template_query_params
    @query_template ||= self.class.query_template
    validate_template!
  end

  def execute = wrap_errors { build_and_execute { connection.execute(@query) } }
  def exec_query = wrap_errors { build_and_execute { connection.exec_query(@query).extend(QuerierDatasetExtensions) } }
  def select_all = wrap_errors { build_and_execute { connection.select_all(@query).extend(QuerierDatasetExtensions) } }
  def select_one = wrap_errors { build_and_execute { connection.select_one(@query) } }
  def select_rows = wrap_errors { build_and_execute { connection.select_rows(@query) } }
  def select_values = wrap_errors { build_and_execute { connection.select_values(@query) } }
  def select_value = wrap_errors { build_and_execute { connection.select_value(@query) } }
  
  def to_sql
    build_query
    @query
  end
  
  def explain
    build_query
    explained_query = "EXPLAIN #{@query}"
    connection.select_all(explained_query).map { it['QUERY PLAN'] }.join("\n")
  end
  
  def count
    build_query
    count_query = "SELECT COUNT(*) FROM (#{@query}) AS count_query"
    connection.select_value(count_query).to_i
  end

  private

  def connection = @active_record_class.connection

  def validate_template!
    raise ArgumentError, "Query template não pode ser vazio" if @query_template.nil? || @query_template.strip.empty?
  end
  
  def build_and_execute
    build_query
    yield
  end
  
  def build_query
    return if @query
    
    required_params = extract_params
    provided_params = @query_params.keys.map(&:to_s)
    missing_params = required_params - provided_params
    
    if missing_params.any? && self.class.param_names.empty?
      raise ArgumentError, "Parâmetros faltando: #{missing_params.join(', ')}"
    end
    
    @query = @query_params.reduce(@query_template.dup) do |q, (param_name, param_value)|
      quoted_value = connection.quote(param_value.to_s)
      q.gsub!("${#{param_name}}", quoted_value)
      q.gsub!("${#{param_name}/no_quote}", param_value.to_s)
      q
    end
  end
  
  def extract_params
    @query_template.scan(/\$\{(\w+)(?:\/no_quote)?\}/).map(&:first).uniq
  end
  
  def wrap_errors
    yield
  rescue ActiveRecord::StatementInvalid => e
    raise QueryError, "Erro ao executar query: #{e.message}\nQuery: #{@query}"
  end
end
