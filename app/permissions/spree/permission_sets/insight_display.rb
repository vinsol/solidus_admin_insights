module Spree
  module PermissionSets
    class InsightDisplay < PermissionSets::Base
      def activate!
        can [:admin, :display, :download], :insights
      end
    end
  end
end
