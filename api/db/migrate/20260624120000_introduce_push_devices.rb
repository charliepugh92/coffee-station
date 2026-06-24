# frozen_string_literal: true

# Introduces a one-device-to-many-subscribers push model:
#   * push_devices       — a browser's push endpoint + crypto keys (one per endpoint)
#   * push_subscriptions — becomes a join linking ONE device to MANY subscribers
#                          (a host User and/or any number of guest Orders)
#
# The old model had a UNIQUE index on endpoint and reassigned the polymorphic
# subscriber on every register, so a single browser could only ever track its
# most recent order — a second order (or host+guest on one phone) silently stole
# the row, leaving readied orders with zero subscriptions and no notification.
#
# EXPAND-ONLY / backward-compatible on purpose. Render runs `rails db:migrate`
# during the BUILD, while the OLD code is still serving traffic, so this migration
# must not break the old code:
#   * the legacy endpoint/p256dh_key/auth_key columns are KEPT (just made nullable)
#     so old PushSubscription.register / WebPushSender keep working in the deploy
#     window;
#   * push_device_id is nullable so old inserts (which don't set it) don't fail.
# A later, separate migration can drop the legacy columns once the old code is no
# longer running anywhere (the contract step). Do NOT add that drop here.
class IntroducePushDevices < ActiveRecord::Migration[8.1]
  def up
    create_table :push_devices do |t|
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.timestamps
    end
    add_index :push_devices, :endpoint, unique: true

    add_reference :push_subscriptions, :push_device, foreign_key: { on_delete: :cascade }

    say_with_time "Backfilling push_devices from existing push_subscriptions" do
      execute(<<~SQL)
        INSERT INTO push_devices (endpoint, p256dh_key, auth_key, created_at, updated_at)
        SELECT endpoint, p256dh_key, auth_key, created_at, updated_at
        FROM push_subscriptions
        ON CONFLICT (endpoint) DO NOTHING;
      SQL
      execute(<<~SQL)
        UPDATE push_subscriptions ps
        SET push_device_id = pd.id
        FROM push_devices pd
        WHERE pd.endpoint = ps.endpoint;
      SQL
    end

    # Legacy device columns become optional: new (join) rows written by the new
    # code carry only push_device_id + subscriber, while old code can still write
    # the legacy columns during the deploy window. NULLs are fine under the kept
    # unique(endpoint) index (Postgres treats NULLs as distinct).
    change_column_null :push_subscriptions, :endpoint, true
    change_column_null :push_subscriptions, :p256dh_key, true
    change_column_null :push_subscriptions, :auth_key, true

    add_index :push_subscriptions, %i[push_device_id subscriber_type subscriber_id],
              unique: true, name: "index_push_subscriptions_on_device_and_subscriber"
  end

  def down
    # The fan-out (one device → many subscribers) cannot be represented by the old
    # unique(endpoint) schema, so reversing would have to silently delete rows.
    # Roll forward instead.
    raise ActiveRecord::IrreversibleMigration,
          "push_devices introduces one-device-to-many-subscribers, which the legacy " \
          "unique(endpoint) schema cannot represent without data loss. Roll forward."
  end
end
