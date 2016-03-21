module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, only: :show
      before_action :set_default_completed_at, only: :show
      before_action :load_reports, only: :index

      def show
        @headers = ReportGenerationService::REPORTS[get_reports_type][@report_name][:headers]
        # params[:q] can be blank upon pagination
        params[:q] = {} if params[:q].blank?
        @search, @stats = ReportGenerationService.public_send(@report_name, params)
      end

      private
        def ensure_report_exists
          @report_name = params[:id].to_sym
          redirect_to admin_insights_path,
            alert: Spree.t(:not_found, scope: [:reports]) unless ReportGenerationService::REPORTS[get_reports_type].include? @report_name
        end

        def load_reports
          @reports = ReportGenerationService::REPORTS[get_reports_type].keys
        end

        def get_reports_type
          params[:type] = params[:type] ? params[:type].to_sym : (session[:report_category].to_sym || ReportGenerationService::REPORTS.keys.first)
          session[:report_category] = params[:type]
        end

        def set_default_completed_at
          params[:q] = {} unless params[:q]
          if params[:q][:orders_completed_at_gt].blank? && @report_name == :users_who_recently_purchased
            params[:q][:orders_completed_at_gt] = Date.current.beginning_of_month
          end

          if params[:q][:orders_completed_at_lt].blank? && @report_name == :users_who_have_not_purchased_recently
            params[:q][:orders_completed_at_lt] = Date.current.end_of_month
          end
        end
    end
  end
end
