module Spree
  class SalesPerformanceReport < Spree::Report
    HEADERS = { sale_price: :integer, cost_price: :integer, promotion_discount: :integer, profit_loss: :integer, profit_loss_percent: :integer }
    SEARCH_ATTRIBUTES = { start_date: :orders_created_from, end_date: :orders_created_till }
    SORTABLE_ATTRIBUTES = []

    def paginated?
      false
    end

    class Result < Spree::Report::TimedResult
      charts ProfitLossChart, ProfitLossPercentChart, SaleCostPriceChart


      class Observation < Spree::Report::TimedObservation
        observation_fields cost_price: 0, sale_price: 0, profit_loss: 0, profit_loss_percent: 0, promotion_discount: 0


        def cost_price
          @cost_price.to_f
        end

        def sale_price
          @sale_price.to_f
        end

        def profit_loss
          @profit_loss.to_f
        end

        def profit_loss_percent
          @profit_loss_percent.to_f
        end

        def promotion_discount
          @promotion_discount.to_f
        end
      end

    end

    def report_query
      q = Spree::Report::QueryFragments
      q.from_union(order_with_line_items_grouped_by_time, promotions_grouped_by_time)
        .group(*zoom_columns_to_s)
        .order(*zoom_columns)
        .project(
          *zoom_columns,
          'SUM(sale_price) as sale_price',
          'SUM(cost_price) as cost_price',
          'SUM(profit_loss) as profit_loss',
          'ROUND((SUM(profit_loss) / SUM(cost_price)) * 100, 2) as profit_loss_percent',
          'SUM(promotion_discount) as promotion_discount'
        )
    end

    def promotions_grouped_by_time
      q = Spree::Report::QueryFragments

      q.from_subquery(promotion_adjustments_with_time)
        .group(*zoom_columns_to_s, 'sale_price', 'cost_price')
        .order(*zoom_columns)
        .project(
          *zoom_columns,
          '0 as sale_price',
          '0 as cost_price',
          'SUM(promotion_discount) * -1 as profit_loss',
          '0 as profit_loss_percent',
          'SUM(promotion_discount) as promotion_discount'
        )
    end

    def promotion_adjustments_with_time
      Spree::Adjustment
        .promotion
        .where(created_at: @start_date..@end_date)
        .select(
          'abs(amount) as promotion_discount',
          *zoom_selects('spree_adjustments')
        )
    end

    def order_with_line_items_grouped_by_time
      q = Spree::Report::QueryFragments
      order_with_line_items_ar = Arel::Table.new(:order_with_line_items)
      zero = Arel::Nodes.build_quoted(0.0)
      q.from_subquery(order_with_line_items, as: :order_with_line_items)
        .group(*zoom_columns_to_s)
        .order(*zoom_columns)
        .project(
          *zoom_columns,
          q.if_null(q.sum(order_with_line_items_ar[:sale_price]), zero).as('sale_price'),
          q.if_null(q.sum(order_with_line_items_ar[:cost_price]), zero).as('cost_price'),
          q.if_null(q.sum(order_with_line_items_ar[:profit_loss]), zero).as('profit_loss'),
          "((#{ q.if_null(q.sum(order_with_line_items_ar[:profit_loss]), zero).to_sql } / SUM(cost_price)) * 100) as profit_loss_percent",
          '0 as promotion_discount'
        )
    end

    def order_with_line_items
      q = Spree::Report::QueryFragments
      line_item_ar = Spree::LineItem.arel_table
      Spree::Order
        .where.not(completed_at: nil)
        .where(created_at: @start_date..@end_date)
        .joins(:line_items)
        .group('spree_orders.id', *zoom_columns_to_s)
        .select(
          *zoom_selects('spree_orders'),
          "spree_orders.item_total as sale_price",
          "SUM(#{ q.if_null(line_item_ar[:cost_price], line_item_ar[:price]).to_sql } * spree_line_items.quantity) as cost_price",
          "(spree_orders.item_total - SUM(#{ q.if_null(line_item_ar[:cost_price], line_item_ar[:price]).to_sql } * spree_line_items.quantity)) as profit_loss"
        )
    end

  end
end
