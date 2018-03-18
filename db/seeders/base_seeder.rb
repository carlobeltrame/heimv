require 'factory_bot_rails'
require 'faker'

module Seeders
  class BaseSeeder
    include FactoryBot::Syntax::Methods
    attr_accessor :seeds, :options

    def initialize(options = {}, seeds = {})
      @options = options
      @seeds = seeds
    end

    def seed; end

    protected

    def production?
      @options.fetch(:env, Rails.env) == :production
    end

    def development?
      @options.fetch(:env, Rails.env) == :development
    end
  end
end
