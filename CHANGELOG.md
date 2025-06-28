# Changelog

## [0.5.0] - 2024-12-XX

### Added
- Fluent DSL for query building with `param` method
- `query_template` method to define template via class method
- Automatic validation of required parameters
- `QueryError` class for better error handling
- `explain` method to visualize execution plan
- `count` method to count records
- `pluck` and `first_value` methods in `QuerierDatasetExtensions` module
- Support for Ruby 3.4+ with implicit parameter `it`
- Explicit dependency on `ostruct`

### Improved
- Lazy query construction (only when needed)
- More descriptive error messages
- Encapsulated error handling with `wrap_errors`
- Extracted `connection` method to reduce duplication
- Updated documentation with examples in Portuguese

### Fixed
- `to_sql` method now exists and returns the generated SQL query
- Tests now use appropriate ActiveRecord mocks

## [0.4.6] - Previous
- Initial version with basic features 