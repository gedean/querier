require 'active_record'

class Querier
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

  def execute = @active_record_class.connection.execute(@query)
  def exec_query = decorate_dataset_format(@active_record_class.connection.exec_query(@query))
  def select_all = decorate_dataset_format(@active_record_class.connection.select_all(@query))
  def select_one = @active_record_class.connection.select_one(@query)
  def select_values = @active_record_class.connection.select_values(@query)
  def select_rows = @active_record_class.connection.select_rows(@query)
  def select_value = @active_record_class.connection.select_value(@query)

  private

  def decorate_dataset_format(dataset)
    def dataset.as_hash = map(&:symbolize_keys)
    def dataset.as_struct = map { |record| OpenStruct.new(record) }
    dataset
  end

  def fill_query_params
    query = @query_template.dup

    @query_params.each do |param_name, param_value|
      placeholder = "${#{param_name}}"
      placeholder_no_quote = "${#{param_name}/no_quote}"
  
      query.gsub!(placeholder, @active_record_class.connection.quote(param_value.to_s))
      query.gsub!(placeholder_no_quote, param_value.to_s)
    end
  
    query
  end
end
