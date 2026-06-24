# frozen_string_literal: true

# Contract half of the push_devices expand/contract (see 20260624120000). The
# expand migration kept push_subscriptions' legacy endpoint/p256dh_key/auth_key
# columns (nullable) so the OLD code could keep serving during its deploy window.
# The new code is now live everywhere and reads device data only from push_devices,
# so these columns are dead weight — drop them.
#
# Run this ONLY after the expand migration's release is fully deployed (it is).
class DropLegacyPushSubscriptionColumns < ActiveRecord::Migration[8.1]
  def up
    # Defensive: catch any rows the old code inserted during the expand deploy
    # window (legacy endpoint present but push_device_id never set) so no real
    # subscription is lost when the columns go.
    say_with_time "Backfilling any window-orphan push_subscriptions" do
      execute(<<~SQL)
        INSERT INTO push_devices (endpoint, p256dh_key, auth_key, created_at, updated_at)
        SELECT DISTINCT ON (endpoint) endpoint, p256dh_key, auth_key, created_at, updated_at
        FROM push_subscriptions
        WHERE push_device_id IS NULL AND endpoint IS NOT NULL
        ORDER BY endpoint, id
        ON CONFLICT (endpoint) DO NOTHING;
      SQL
      execute(<<~SQL)
        UPDATE push_subscriptions ps
        SET push_device_id = pd.id
        FROM push_devices pd
        WHERE ps.push_device_id IS NULL AND pd.endpoint = ps.endpoint;
      SQL
    end

    # Anything still unlinked can't be represented in the new model; it's an
    # unusable orphan (delivery goes through push_devices), so remove it.
    execute("DELETE FROM push_subscriptions WHERE push_device_id IS NULL;")

    remove_index :push_subscriptions, :endpoint, unique: true,
                 name: "index_push_subscriptions_on_endpoint"
    remove_column :push_subscriptions, :endpoint, :string
    remove_column :push_subscriptions, :p256dh_key, :string
    remove_column :push_subscriptions, :auth_key, :string

    change_column_null :push_subscriptions, :push_device_id, false
  end

  def down
    # Structural reverse to the post-expand schema (columns back, nullable). The
    # legacy column DATA is not restored — it lived redundantly in push_devices —
    # and the unique(endpoint) index is intentionally not re-added (it can't
    # represent one-device-to-many-subscribers). Roll forward in production.
    change_column_null :push_subscriptions, :push_device_id, true
    add_column :push_subscriptions, :endpoint, :string
    add_column :push_subscriptions, :p256dh_key, :string
    add_column :push_subscriptions, :auth_key, :string
  end
end
