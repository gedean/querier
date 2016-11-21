require_relative '../lib/querier'

TEST_USER_NAME = 'foo'
VALID_QUERY = "SELECT * FROM users	WHERE name = '#{TEST_USER_NAME}' AND active = true"

class UserQuerier < Querier
  def initialize user_name:, active:
    @query_template = "SELECT * FROM users	WHERE name = {?user_name} AND active = {?active}"
    super
  end
end

describe Querier do

before :each do
	@user_querier = UserQuerier.new(user_name: TEST_USER_NAME, active: true)
end

	it 'Returns a valid query' do
		expect(@user_querier.to_sql).to eq VALID_QUERY
	end
end