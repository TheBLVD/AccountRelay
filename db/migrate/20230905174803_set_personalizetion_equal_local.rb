class SetPersonalizetionEqualLocal < ActiveRecord::Migration[6.1]
  def self.up
    User.update_all('personalize=local')
  end

  def self.down; end
end
