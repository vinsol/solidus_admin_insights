module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, :set_default_completed_at, :set_default_pagination, only: :show
      before_action :load_reports, only: :index

      def show
        @headers, @stats, @total_records = ReportGenerationService.public_send(
                                             :generate_report,
                                             @report_name,
                                             params.merge(@pagination_hash)
                                           )

        fetch_total_pages

        respond_to do |format|
          format.html
          format.json {
            render json: {
              headers:          @headers,
              request_fullpath: request.fullpath,
              request_path: request.path,
              stats:            @stats,
              total_pages:      @total_pages,
              url:              request.url
            }
          }
        end
      end

      private
        def ensure_report_exists
          @report_name = params[:id].to_sym
          unless ReportGenerationService::REPORTS[get_reports_type].include? @report_name
            redirect_to admin_insights_path, alert: Spree.t(:not_found, scope: [:reports])
          end
        end

        def load_reports
          @reports = ReportGenerationService::REPORTS[get_reports_type]
        end

        def get_reports_type
          params[:type] = if params[:type]
            params[:type].to_sym
          else
            session[:report_category].to_sym || ReportGenerationService::REPORTS.keys.first
          end
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

        def set_default_pagination
          @pagination_hash = {}
          @pagination_hash[:records_per_page] = params[:per_page] || Spree::Config[:records_per_page]
          @pagination_hash[:offset] = params[:page].to_i * @pagination_hash[:records_per_page]
        end

        def fetch_total_pages
          @total_pages = @total_records / @pagination_hash[:records_per_page]
          if @total_records % @pagination_hash[:records_per_page] == 0
            @total_pages -= 1
          end
        end

    end
  end
end
