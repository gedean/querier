# Querier: Simple Parameterized SQL Execution with ActiveRecord

This library allows you to create and execute custom SQL queries safely and easily using ActiveRecord, with support for parameterized templates and practical result formats.

## Module: `QuerierDatasetExtensions`

Adds useful methods to query results:

- `as_hash`: converts each record to a hash with symbol keys.
- `as_struct`: converts each record to an `OpenStruct` for dot access.

## Class: `Querier`

Makes it easy to execute custom SQL for any ActiveRecord model, using templates with replaceable parameters.

### Main Features

- Safe parameter substitution using `${param}` (with quote) and `${param/no_quote}` (no quote, for validated column names or lists).
- Methods to execute queries and return results in various formats.
- Easy extension via subclasses for reusable queries.

### Execution Methods

- `execute`: runs the query (no structured return)
- `exec_query`: returns `ActiveRecord::Result` with extra methods
- `select_all`, `select_one`, `select_rows`, `select_values`, `select_value`: various return types as needed

## Usage Example

```ruby
# Example of a custom query to fetch users
class UserQuerier < Querier
  def initialize(user_name:, active:, ages:)
    @query_template = 'SELECT * FROM users WHERE name = ${user_name} AND active = ${active} AND age IN (${ages/no_quote})'
    super
  end
end

# Parameters
user_name = 'joao'
active = true
ages = [25, 30, 40].join(', ')

# Instantiating and executing
query = UserQuerier.new(user_name: user_name, active: active, ages: ages)
result = query.select_all

# Converting result to hash or struct
puts result.as_hash
puts result.as_struct
```

### Example of a Math Query

```ruby
class YearsQuerier < Querier
  def initialize(start_year:, end_year:)
    @query_template = 'SELECT ${end_year} - ${start_year} AS diff'
    super
  end
end

query = YearsQuerier.new(start_year: 2020, end_year: 1992)
puts query.select_value # => 28
```

## Security

- Use `${param}` for dynamic values (always quoted, safe against SQL injection).
- Use `${param/no_quote}` **only** for validated values (e.g., column names, pre-processed lists).

## Summary

Querier centralizes and simplifies the execution of custom SQL with ActiveRecord, promoting safety, reusability, and practical result handling.

