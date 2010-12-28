require 'rails/generators/active_record'

class ConfigureMeGenerator < ActiveRecord::Generators::Base #Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  def generate_model
    template 'model.rb', "app/models/#{singular_name}.rb"
  end

  def generate_migration
    migration_template 'migration.rb', "db/migrate/create_#{plural_name}.rb"
  end

  def generate_initializer
    template 'initializer.rb', 'config/initializers/init_configure_me.rb'
  end
end
