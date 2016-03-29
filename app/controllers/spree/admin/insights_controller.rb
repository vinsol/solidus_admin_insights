module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, only: :show
      before_action :set_default_completed_at, only: :show
      before_action :load_reports, only: :index

      def show
        @headers = Spree.const_get((@report_name.to_s + '_report').classify)::HEADERS
        @stats = ReportGenerationService.public_send(@report_name, params)
        respond_to do |format|
          format.html
          format.json {
            render json: {
              headers: @headers.map { |header| { name: header.to_s.humanize, value: header } },
              stats: @stats,
              request_fullpath: request.fullpath
            }
          }
        end
      end

      private
        def ensure_report_exists
          @report_name = params[:id].to_sym
          redirect_to admin_insights_path,
            alert: Spree.t(:not_found, scope: [:reports]) unless ReportGenerationService::REPORTS[get_reports_type].include? @report_name
        end

        def load_reports
          @reports = ReportGenerationService::REPORTS[get_reports_type]
        end

        def get_reports_type
          params[:type] = params[:type] ? params[:type].to_sym : (session[:report_category].to_sym || ReportGenerationService::REPORTS.keys.first)
          session[:report_category] = params[:type]
        end

        def set_default_completed_at
          params[:search] = {} unless params[:search]
          if params[:search][:start_date].blank? && @report_name == :users_who_recently_purchased
            params[:search][:start_date] = Date.current.beginning_of_month
          end

          if params[:search][:end_date].blank? && @report_name == :users_who_have_not_purchased_recently
            params[:search][:end_date] = Date.current.end_of_month
          end
        end
    end
  end
end
