# Querier Class for ActiveRecord Custom SQL Queries

This README explains the functionality and use of the `Querier` class, designed to facilitate the construction and execution of custom SQL queries in a Ruby on Rails environment using ActiveRecord.

## Module: `QuerierDatasetExtensions`

The `QuerierDatasetExtensions` module extends the results returned by SQL queries with utility methods for easy data transformation:

- `as_hash`: Converts each record into a hash with symbolized keys, making it easier to work with the data.
- `as_struct`: Converts each record into an `OpenStruct` instance, allowing attribute access using dot notation.

## Class: `Querier`

The `Querier` class is designed to simplify the execution of custom SQL queries on a specific ActiveRecord model. Below are the detailed explanations of its components:

### 1. Class Variable and Singleton Attribute

The class uses a singleton attribute (`@active_record_class`) to maintain a reference to the ActiveRecord class that will be used to execute queries.

Instead of using class variables (`@@`), which are generally discouraged due to inheritance and concurrency issues, the implementation uses the recommended approach of using singleton class attributes with `attr_accessor` defined within the `class << self` context.

### 2. Attributes and Initialization

- **`@query_params`**: Stores the parameters that will be used to fill in the query template.
- **`@active_record_class`**: Initialized with the ActiveRecord class defined by the class or superclass. This allows the `Querier` class to be reused for different ActiveRecord models.

### 3. Public Execution Methods

The `Querier` class provides several methods to execute SQL queries, wrapping the ActiveRecord connection methods:

- `execute`: Executes the query without returning structured records.
- `exec_query`: Executes the query and returns results as an `ActiveRecord::Result`, extended with the `QuerierDatasetExtensions` module.
- `select_all`, `select_one`, `select_rows`, `select_values`, `select_value`: These methods provide different formats for returning the query results, such as all records, a single record, rows, values, or a specific value.

### 4. Filling Query Parameters (`fill_query_params`)

The private `fill_query_params` method is responsible for parameter interpolation within the `@query_template`.

- There are two types of placeholders for parameters in the query:
  - `${param_name}`: This placeholder is replaced by the parameter value, escaped using the ActiveRecord connection's `quote` method to prevent SQL injection.
  - `${param_name/no_quote}`: This placeholder substitutes the value directly without escaping, which is useful when the value is not susceptible to SQL injection (e.g., column names).

### Security Considerations

- The use of `${param_name/no_quote}` should be done cautiously, as it may introduce vulnerabilities if used with unvalidated inputs. It is recommended to restrict its use to validated column names only.

### Error Handling

Currently, there is no error handling. Adding a `begin-rescue` block in the execution methods could improve robustness, handling issues such as connection failures or SQL syntax errors gracefully.

### Query Template Separation

The `@query_template` is not explicitly defined in the provided code. It is recommended to use subclasses or clearly pass a query template, following good design practices to reuse query templates effectively.

### Interface Improvement

Adding methods that accept queries directly as arguments could make the class more flexible and easier to use in scenarios where a dynamic query is needed.

## Example Usage

Below is an example of how to use the `Querier` class:

```ruby
class MyCustomQuery < Querier
  QUERY_TEMPLATE = <<-END_TEMPLATE
  SELECT * FROM users WHERE id = ${user_id}
  END_TEMPLATE

  def initialize(user_id)
    @query_template = QUERY_TEMPLATE
    super
  end
end

query = MyCustomQuery.new(1)
result = query.select_one
puts result # => Returns the user record with id 1
```

This example demonstrates how the `Querier` class can be used to create specific queries for different purposes, making it easier to organize and reuse SQL queries.

## Summary

The `Querier` class provides a convenient way to build and execute custom SQL queries while keeping the process organized. It also enables centralized control for constructing and executing SQL within the context of ActiveRecord. The addition of the `QuerierDatasetExtensions` module further enhances the ease of transforming and using query results.

