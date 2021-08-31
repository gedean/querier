require 'active_record'
require_relative '../lib/querier'

TEST_USER_NAME = 'foo'.freeze
TEST_AGES = [25, 35, 42].join(', ').freeze # this param is for no quotes test porpourses
VALID_QUERY = "SELECT * FROM users WHERE name = '#{TEST_USER_NAME}' AND active = true AND AGE IN (25, 35, 42) -- Valid Ages: '25, 35, 42'".freeze

class UserQuerier < Querier
  def initialize(user_name:, active:, ages:)
    @query_template = 'SELECT * FROM users WHERE name = ${user_name} AND active = ${active} AND AGE IN (${ages/no_quote}) -- Valid Ages: ${ages}'
    super
  end
end

class YearsQuerier < Querier
  def initialize(start_year:, end_year:)
    @query_template = 'SELECT ${end_year} - ${start_year} AS diff'
    super
  end
end

describe Querier do
  before :each do
    @user_querier = UserQuerier.new(user_name: TEST_USER_NAME, active: true, ages: TEST_AGES)
    puts 'Valid Query:'
    puts VALID_QUERY
    puts 'Template Query:'
    puts @user_querier.query_template
    puts 'Generated Query:'
    puts @user_querier.to_sql
  end

  it 'Returns a valid query' do
    expect(@user_querier.to_sql).to eq VALID_QUERY
  end
end

describe 'Query Execution' do
  before :each do
    @years_query = YearsQuerier.new(start_year: 2020, end_year: 1992)
  end

  it 'Returns difference between years' do
    expect(@years_query.execute).to eq 28
  end
end
