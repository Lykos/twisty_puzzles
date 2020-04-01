# frozen_string_literal: true

require Rails.root.join('db/migrate/20200401001041_add_admin.rb')

describe AddAdmin do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) {  }
  let(:current_version) {  }
  subject { ActiveRecord::Migrator.new(action, migrations, version_after_action).migrate }

  around do |example|
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      # Migrate back to the version before the action runs
      # Note that for down, this is actually the current version.
      ActiveRecord::Migrator.new(inverse_action, migrations, version_before_action).migrate

      # If other tests using User table ran before this one, Rails has
      # stored information about table's columns and we need to reset those
      # since the migration changed the database structure.
      User.reset_column_information

      example.run

      # Re-update column information after the migration has been executed
      # again in the example. This will make user attributes cache
      # ready for other tests.
      User.reset_column_information
    end
  end

  describe :up do
    let(:action) { :up }
    let(:inverse_action) { :down }
    let(:version_before_action) { previous_version }
    let(:version_after_action) { current_version }

    pending 'describe up'
  end

  describe :down do
    let(:action) { :down }
    let(:inverse_action) { :up }
    let(:version_before_action) { current_version }
    let(:version_after_action) { previous_version }

    pending 'describe down'
  end
end
