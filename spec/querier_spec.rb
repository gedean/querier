require 'active_record'
require_relative '../lib/querier'

RSpec.describe Querier do
  let(:mock_connection) { double('connection') }
  let(:mock_ar_class) { double('ActiveRecord::Base', connection: mock_connection) }
  
  before do
    allow(mock_connection).to receive(:quote) { |value| "'#{value}'" }
    Querier.active_record_class = mock_ar_class
  end

  describe 'UserQuerier' do
    class UserQuerier < Querier
      def initialize(user_name:, active:, ages:)
        @query_template = 'SELECT * FROM users WHERE name = ${user_name} AND active = ${active} AND AGE IN (${ages/no_quote}) -- Valid Ages: ${ages}'
        super
      end
    end

    let(:user_name) { 'foo' }
    let(:ages) { '25, 35, 42' }
    let(:user_querier) { UserQuerier.new(user_name: user_name, active: true, ages: ages) }
    let(:expected_query) { "SELECT * FROM users WHERE name = '#{user_name}' AND active = 'true' AND AGE IN (#{ages}) -- Valid Ages: '#{ages}'" }

    it 'gera uma query válida' do
      expect(user_querier.to_sql).to eq(expected_query)
    end

    it 'tem o template correto' do
      expect(user_querier.query_template).to include('${user_name}')
      expect(user_querier.query_template).to include('${active}')
      expect(user_querier.query_template).to include('${ages/no_quote}')
    end
  end

  describe 'YearsQuerier' do
    class YearsQuerier < Querier
      def initialize(start_year:, end_year:)
        @query_template = 'SELECT ${end_year} - ${start_year} AS diff'
        super
      end
    end

    let(:years_querier) { YearsQuerier.new(start_year: 1992, end_year: 2020) }

    it 'gera query de cálculo corretamente' do
      expect(years_querier.to_sql).to eq("SELECT '2020' - '1992' AS diff")
    end

    it 'executa e retorna valor' do
      allow(mock_connection).to receive(:select_value).and_return(28)
      expect(years_querier.select_value).to eq(28)
    end
  end

  describe 'validações' do
    class EmptyQuerier < Querier
      def initialize
        @query_template = ''
        super
      end
    end

    class MissingParamsQuerier < Querier
      def initialize(name:)
        @query_template = 'SELECT * FROM users WHERE name = ${name} AND age = ${age}'
        super
      end
    end

    it 'lança erro quando template está vazio' do
      expect { EmptyQuerier.new }.to raise_error(ArgumentError, "Query template não pode ser vazio")
    end

    it 'lança erro quando parâmetros estão faltando' do
      querier = MissingParamsQuerier.new(name: 'João')
      expect { querier.to_sql }.to raise_error(ArgumentError, "Parâmetros faltando: age")
    end
  end

  describe 'DSL' do
    class DslQuerier < Querier
      query_template 'SELECT * FROM products WHERE price = ${price} AND category = ${category}'
      param :price, :category
    end

    it 'permite uso de DSL fluente' do
      querier = DslQuerier.new.price(10.50).category('Books')
      expect(querier.to_sql).to eq("SELECT * FROM products WHERE price = '10.5' AND category = 'Books'")
    end

    it 'permite definir template via método de classe' do
      expect(DslQuerier.query_template).to eq('SELECT * FROM products WHERE price = ${price} AND category = ${category}')
    end
  end

  describe 'métodos adicionais' do
    let(:simple_querier) do
      class SimpleQuerier < Querier
        def initialize
          @query_template = 'SELECT * FROM users'
          super
        end
      end
      SimpleQuerier.new
    end

    it 'gera EXPLAIN da query' do
      allow(mock_connection).to receive(:select_all).and_return([{'QUERY PLAN' => 'Seq Scan on users'}])
      expect(simple_querier.explain).to eq('Seq Scan on users')
    end

    it 'conta registros da query' do
      allow(mock_connection).to receive(:select_value).and_return(42)
      expect(simple_querier.count).to eq(42)
    end
  end

  describe 'tratamento de erros' do
    let(:error_querier) do
      class ErrorQuerier < Querier
        def initialize
          @query_template = 'SELECT * FROM invalid_table'
          super
        end
      end
      ErrorQuerier.new
    end

    it 'encapsula erros do ActiveRecord' do
      allow(mock_connection).to receive(:select_all).and_raise(ActiveRecord::StatementInvalid, 'table not found')
      expect { error_querier.select_all }.to raise_error(Querier::QueryError, /Erro ao executar query/)
    end
  end

  describe 'QuerierDatasetExtensions' do
    let(:result_array) { [{'name' => 'João', 'age' => 25}, {'name' => 'Maria', 'age' => 30}] }
    
    before do
      result_array.extend(QuerierDatasetExtensions)
    end

    it 'converte para hash com chaves simbólicas' do
      expect(result_array.as_hash).to eq([{name: 'João', age: 25}, {name: 'Maria', age: 30}])
    end

    it 'converte para struct' do
      structs = result_array.as_struct
      expect(structs.first.name).to eq('João')
      expect(structs.first.age).to eq(25)
    end

    it 'pluck uma coluna' do
      expect(result_array.pluck(:name)).to eq(['João', 'Maria'])
    end

    it 'pluck múltiplas colunas' do
      expect(result_array.pluck(:name, :age)).to eq([['João', 25], ['Maria', 30]])
    end

    it 'retorna primeiro valor' do
      expect(result_array.first_value).to eq('João')
    end
  end
end
