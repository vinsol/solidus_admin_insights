module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, only: :show
      before_action :load_reports, only: :index

      def show
        @headers = ReportGenerationService::REPORTS[@report_name][:headers]
        # params[:q] can be blank upon pagination
        params[:q] = {} if params[:q].blank?
        @search, @stats = ReportGenerationService.public_send(@report_name, params)
      end

      private
        def ensure_report_exists
          @report_name = params[:id].to_sym
          redirect_to admin_insights_path,
            alert: Spree.t(:not_found, scope: [:reports]) unless ReportGenerationService::REPORTS.include? @report_name
        end

        def load_reports
          @reports = ReportGenerationService::REPORTS.keys
        end
    end
  end
end
