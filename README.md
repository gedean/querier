# querier

# class UserQuerier < Querier
    def initialize user_name:, active:
        @query_template = "SELECT * FROM users WHERE name = ${user_name} AND active = ${active}"
        super
    end
end

# UserQuerier.new(user_name: 'foo', active: true).execute
