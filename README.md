# querier

# class UserQuerier < Querier
    QUERY_TEMPLATE = <<-END_OF_QUERY_TEMPLATE

SELECT
  *
FROM
  users
WHERE
  name = {?user_name}
  AND active = {?active}

  END_OF_QUERY_TEMPLATE

    def initialize user_name:, active:
        @query_template = QUERY_TEMPLATE
        super
    end
end

# UserQuerier.new(user_name: foo, active: true).execute