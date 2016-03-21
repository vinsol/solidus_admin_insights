module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, only: :show
      before_action :load_reports, only: :index

      def show
        @headers = ReportGenerator::REPORTS[@report_name][:headers]
        # params[:q] can be blank upon pagination
        params[:q] = {} if params[:q].blank?
        @search, @stats = ReportGenerator.public_send(@report_name, params)
      end

      private
        def ensure_report_exists
          @report_name = params[:id].to_sym
          redirect_to admin_insights_path,
            alert: Spree.t(:not_found, scope: [:reports]) unless ReportGenerator::REPORTS.include? @report_name
        end

        def load_reports
          @reports = ReportGenerator::REPORTS.keys
        end
    end
  end
end
