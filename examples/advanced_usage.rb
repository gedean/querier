require_relative '../lib/querier'

class ReportQuerier < Querier
  def initialize(start_date:, end_date:, status: nil, limit: 10)
    @query_template = <<~SQL
      SELECT 
        id,
        title,
        status,
        created_at,
        updated_at
      FROM reports
      WHERE created_at BETWEEN ${start_date} AND ${end_date}
      #{status ? "AND status = ${status}" : ""}
      ORDER BY created_at DESC
      LIMIT ${limit/no_quote}
    SQL
    
    params = { start_date: start_date, end_date: end_date, limit: limit }
    params[:status] = status if status
    
    super(params)
  end
end

class StatsQuerier < Querier
  def initialize(table_name:, group_by:, aggregation: 'COUNT(*)')
    @query_template = <<~SQL
      SELECT 
        ${group_by/no_quote} as group_field,
        ${aggregation/no_quote} as value
      FROM ${table_name/no_quote}
      GROUP BY ${group_by/no_quote}
      ORDER BY value DESC
    SQL
    
    super(table_name: table_name, group_by: group_by, aggregation: aggregation)
  end
end

class BulkInsertQuerier < Querier
  def initialize(table:, columns:, values:)
    values_list = values.map { |row| 
      "(#{row.map { |v| "'#{v}'" }.join(', ')})" 
    }.join(', ')
    
    @query_template = <<~SQL
      INSERT INTO ${table/no_quote} (${columns/no_quote})
      VALUES ${values/no_quote}
    SQL
    
    super(table: table, columns: columns.join(', '), values: values_list)
  end
end

if __FILE__ == $0
  puts "=== Exemplo de Report Query ==="
  report_query = ReportQuerier.new(
    start_date: '2024-01-01', 
    end_date: '2024-12-31',
    status: 'completed',
    limit: 20
  )
  puts report_query.to_sql
  
  puts "\n=== Exemplo de Stats Query ==="
  stats_query = StatsQuerier.new(
    table_name: 'orders',
    group_by: 'status',
    aggregation: 'SUM(total)'
  )
  puts stats_query.to_sql
  
  puts "\n=== Exemplo de Bulk Insert ==="
  bulk_insert = BulkInsertQuerier.new(
    table: 'products',
    columns: ['name', 'price', 'category'],
    values: [
      ['Produto A', 10.50, 'Eletrônicos'],
      ['Produto B', 25.00, 'Livros'],
      ['Produto C', 5.99, 'Alimentos']
    ]
  )
  puts bulk_insert.to_sql
end 