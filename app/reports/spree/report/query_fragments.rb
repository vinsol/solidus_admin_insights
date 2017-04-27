module Spree::Report::QueryFragments
  def self.from_subquery(subquery, as: 'results')
    Arel::SelectManager.new(Arel.sql("(#{subquery.to_sql}) as #{ as }"))
  end

  def self.from_join(subquery1, subquery2, join_expr)
    Arel::SelectManager.new(Arel.sql("((#{ subquery1.to_sql }) as q1 JOIN (#{ subquery2.to_sql }) as q2 ON #{ join_expr })"))
  end

  def self.from_union(subquery1, subquery2)
    Arel::SelectManager.new(Arel.sql("((#{ subquery1.to_sql }) UNION (#{ subquery2.to_sql })) as results"))
  end

  def self.year(column, as='year')
    extract_from_date(:year, column, as)
  end

  def self.month(column, as='month')
    extract_from_date(:month, column, as)
  end

  def self.week(column, as='week')
    extract_from_date(:week, column, as)
  end

  def self.day(column, as='day')
    extract_from_date(:day, column, as)
  end

  def self.hour(column, as='hour')
    extract_from_date(:hour, column, as)
  end

  def self.when()

  end

  def self.extract_from_date(part, column, as)
    "EXTRACT('#{ part }' from #{ column }) AS #{ as }"
  end
end
