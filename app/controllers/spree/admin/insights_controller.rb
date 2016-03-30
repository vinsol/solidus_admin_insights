module Spree
  module Admin
    class InsightsController < Spree::Admin::BaseController
      before_action :ensure_report_exists, only: :show
      before_action :set_default_completed_at, only: :show
      before_action :load_reports, only: :index
      before_action :set_default_pagination, only: :show

      def show
        @headers = Spree.const_get((@report_name.to_s + '_report').classify)::HEADERS
        @stats, @total_records = ReportGenerationService.public_send(@report_name, params.merge(@pagination_hash))
        get_total_pages

        respond_to do |format|
          format.html
          format.json {
            render json: {
              headers: @headers.map { |header| { name: header.to_s.humanize, value: header } },
              stats: @stats,
              request_fullpath: request.fullpath,
              total_pages: @total_pages,
              url: request.url
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
          params[:q] = {} unless params[:q]
          if params[:q][:orders_completed_at_gt].blank? && @report_name == :users_who_recently_purchased
            params[:q][:orders_completed_at_gt] = Date.current.beginning_of_month
          end

          if params[:q][:orders_completed_at_lt].blank? && @report_name == :users_who_have_not_purchased_recently
            params[:q][:orders_completed_at_lt] = Date.current.end_of_month
          end
        end

        def set_default_pagination
          @pagination_hash = {}
          @pagination_hash[:records_per_page] = params[:per_page] || Spree::Config[:records_per_page]
          @pagination_hash[:offset] = params[:page].to_i * @pagination_hash[:records_per_page]
        end

        def get_total_pages
          @total_pages = @total_records/@pagination_hash[:records_per_page]
          if @total_records % @pagination_hash[:records_per_page] == 0
            @total_pages -= 1
          end
        end

    end
  end
end
