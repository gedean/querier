require_relative '../lib/querier'

TEST_USER_NAME = 'foo'
TEST_AGES = [25, 35, 42].join(', ') # this param is for no quotes test porpourses
VALID_QUERY = "SELECT * FROM users WHERE name = '#{TEST_USER_NAME}' AND active = true AND AGE IN (25, 35, 42) -- Valid Ages: '25, 35, 42'"

class UserQuerier < Querier
  def initialize user_name:, active:, ages:
    @query_template = "SELECT * FROM users WHERE name = {?user_name} AND active = {?active} AND AGE IN ({?ages/no_quote}) -- Valid Ages: {?ages}"
    super
  end
end

describe Querier do

before :each do
	@user_querier = UserQuerier.new(user_name: TEST_USER_NAME, active: true, ages: TEST_AGES)
end

	it 'Returns a valid query' do
		expect(@user_querier.to_sql).to eq VALID_QUERY
	end
end