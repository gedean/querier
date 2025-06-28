require_relative '../lib/querier'

# Mock de conexão para demonstração
class MockConnection
  def quote(value)
    "'#{value}'"
  end
end

class MockActiveRecord
  def self.connection
    @connection ||= MockConnection.new
  end
end

# Configurar Querier para usar o mock
Querier.active_record_class = MockActiveRecord

class ProductSearchQuerier < Querier
  query_template <<~SQL
    SELECT 
      p.id,
      p.name,
      p.price,
      c.name as category_name
    FROM products p
    JOIN categories c ON p.category_id = c.id
    WHERE 1=1
      AND p.price BETWEEN ${min_price} AND ${max_price}
      AND c.name = ${category}
      AND p.active = ${active}
    ORDER BY p.price ASC
    LIMIT ${limit/no_quote}
  SQL
  
  param :min_price, :max_price, :category, :active, :limit
end

class UserActivityQuerier < Querier
  query_template 'SELECT * FROM activities WHERE user_id = ${user_id} AND created_at >= ${since}'
  
  param :user_id, :since
  
  def recent(days = 7)
    since((Date.today - days).to_s)
  end
  
  def today
    since(Date.today.to_s)
  end
end

if __FILE__ == $0
  puts "=== Busca de Produtos com DSL ==="
  
  search = ProductSearchQuerier.new
    .min_price(10.0)
    .max_price(100.0)
    .category('Eletrônicos')
    .active(true)
    .limit(5)
  
  puts search.to_sql
  
  puts "\n=== Atividades do Usuário ==="
  
  activities = UserActivityQuerier.new
    .user_id(123)
    .recent(30)
  
  puts activities.to_sql
  
  puts "\n=== Atividades de Hoje ==="
  
  today_activities = UserActivityQuerier.new
    .user_id(456)
    .today
  
  puts today_activities.to_sql
  
  puts "\n=== Query Complexa com Builder Pattern ==="
  
  # Demonstrando construção incremental
  query = ProductSearchQuerier.new
  query.min_price(50.0)
  query.max_price(500.0)
  
  # Adicionar filtros condicionalmente
  query.category('Livros') if true
  query.active(true)
  query.limit(10)
  
  puts query.to_sql
end 