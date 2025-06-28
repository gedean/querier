# Querier: Parameterized SQL Execution with ActiveRecord

Ruby gem for executing custom SQL queries safely and elegantly using ActiveRecord, with support for parameterized templates, fluent DSL, and practical result formats.

## Installation

```ruby
gem 'querier'
```

## Main Features

- ✅ Safe parameter substitution against SQL injection
- ✅ Fluent DSL for query building
- ✅ Automatic validation of required parameters
- ✅ Convenience methods for different result formats
- ✅ Enhanced error handling
- ✅ Support for EXPLAIN and COUNT
- ✅ Useful extensions for results (as_hash, as_struct, pluck)

## Basic Usage

### Creating a Simple Query

```ruby
class UserQuerier < Querier
  def initialize(name:, active:)
    @query_template = 'SELECT * FROM users WHERE name = ${name} AND active = ${active}'
    super
  end
end

query = UserQuerier.new(name: 'John', active: true)
users = query.select_all.as_hash
```

### Using Fluent DSL

```ruby
class ProductQuerier < Querier
  query_template 'SELECT * FROM products WHERE price BETWEEN ${min} AND ${max}'
  param :min, :max
end

products = ProductQuerier.new
  .min(10.0)
  .max(100.0)
  .select_all
  .as_struct
```

## Execution Methods

- `execute` - Executes the query (no structured return)
- `exec_query` - Returns `ActiveRecord::Result` with extra methods
- `select_all` - Returns array of hashes
- `select_one` - Returns a single hash
- `select_rows` - Returns array of arrays
- `select_values` - Returns array of values from one column
- `select_value` - Returns a single value
- `to_sql` - Returns the generated SQL query
- `explain` - Returns the execution plan
- `count` - Returns record count

## Dataset Extensions

```ruby
result = query.select_all

# Convert to hash with symbolic keys
result.as_hash

# Convert to OpenStruct
result.as_struct

# Extract values from specific columns
result.pluck(:name)           # ['John', 'Mary']
result.pluck(:name, :email)   # [['John', 'j@email.com'], ['Mary', 'm@email.com']]

# First value of first record
result.first_value  # 'John'
```

## Safe vs Unquoted Parameters

```ruby
# ${param} - Always quoted (safe for user values)
@query_template = 'SELECT * FROM users WHERE email = ${email}'

# ${param/no_quote} - Not quoted (only for validated values)
@query_template = 'SELECT * FROM ${table/no_quote} WHERE id IN (${ids/no_quote})'
```

## Advanced Example

```ruby
class ReportQuerier < Querier
  query_template <<~SQL
    SELECT 
      DATE(created_at) as date,
      COUNT(*) as total,
      SUM(amount) as revenue
    FROM orders
    WHERE created_at BETWEEN ${start_date} AND ${end_date}
      AND status = ${status}
    GROUP BY DATE(created_at)
    ORDER BY date DESC
  SQL
  
  param :start_date, :end_date, :status
  
  def last_30_days
    start_date(30.days.ago.to_date.to_s)
    end_date(Date.today.to_s)
    self
  end
end

# Usage
report = ReportQuerier.new
  .last_30_days
  .status('completed')

# View SQL
puts report.to_sql

# Execute and format
results = report.select_all.as_struct
results.each do |day|
  puts "#{day.date}: #{day.total} orders, $ #{day.revenue}"
end
```

## Error Handling

```ruby
begin
  query.select_all
rescue Querier::QueryError => e
  puts "Query error: #{e.message}"
end
```

## Security

- Use `${param}` for all dynamic values from the user
- Use `${param/no_quote}` only for pre-validated values (column names, processed lists)
- The gem automatically validates that all required parameters have been provided

## License

MIT

