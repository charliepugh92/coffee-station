# frozen_string_literal: true

module Types
  module Enums
    class SessionStatusEnum < BaseEnum
      description "Whether a session is currently open (accepting orders) or closed"
      generate_from_rails_enum Session.statuses
    end
  end
end
