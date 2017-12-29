require 'spec_helper'
require 'aws-ssm-env/naming_strategies/snakecase'

describe AwsSsmEnv::SnakeCaseNamingStrategy do
  let(:strategy) { described_class.new(args) }
  let(:name) { 'path.to.db/password' }
  let(:env_name) { strategy.parse_name(Parameter.new(name)) }

  describe '#parse_name' do
    context 'when :removed_prefix was not set' do
      context 'when :begins_with was not set' do
        let(:args) { {} }
        it 'return converted path hierarchy into snake case' do
          expect(env_name).to eq('PATH.TO.DB_PASSWORD')
        end
      end

      context 'when :begins_with was set' do
        let(:args) { { begins_with: 'path.to.' } }
        it 'return converted path hierarchy without begins_with into snake case' do
          expect(env_name).to eq('DB_PASSWORD')
        end
      end

      context 'when :path was set' do
        let(:args) { { path: 'path.to.' } }
        it 'return converted path hierarchy without begins_with into snake case' do
          expect(env_name).to eq('DB_PASSWORD')
        end
      end
    end

    context 'when :removed_prefix was set' do
      context 'when :begins_with was not set' do
        let(:args) { { removed_prefix: 'path.' } }
        it 'return converted path hierarchy without removed_prefix into snake case' do
          expect(env_name).to eq('TO.DB_PASSWORD')
        end
      end

      context 'when :begins_with was set' do
        let(:args) { { removed_prefix: 'path.', begins_with: 'path.to.' } }
        it 'return converted path hierarchy without removed_prefix into snake case' do
          expect(env_name).to eq('TO.DB_PASSWORD')
        end
      end

      context 'when :path was set' do
        let(:args) { { removed_prefix: 'path.', path: 'path.to.' } }
        it 'return converted path hierarchy without removed_prefix into snake case' do
          expect(env_name).to eq('TO.DB_PASSWORD')
        end
      end
    end

    context 'when :delimiter was not set' do
      let(:args) { { removed_prefix: 'path.' } }

      it 'return converted path hierarchy with replace "/" to "_"' do
        expect(env_name).to eq('TO.DB_PASSWORD')
      end
    end

    context 'when :delimiter was set' do
      let(:args) { { removed_prefix: 'path.', delimiter: %r{[./]} } }

      it 'return converted path hierarchy with replace "/" or "." to "_"' do
        expect(env_name).to eq('TO_DB_PASSWORD')
      end
    end
  end
end
