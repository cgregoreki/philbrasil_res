class AddSolvedFlagToReportBadArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :report_bad_articles, :solved, :boolean

  end
end
