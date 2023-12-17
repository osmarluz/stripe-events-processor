# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :external_id
      t.string :source
      t.jsonb :data
      t.string :state
      t.datetime :paid_at
      t.datetime :canceled_at

      t.index %i[external_id source], unique: true

      t.timestamps
    end
  end
end
