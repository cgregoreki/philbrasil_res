class CreateReportBadArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :report_bad_articles do |t|
        t.text :description
        t.string :reporter_name
        t.string :reporter_email

        t.belongs_to :article, foreign_key: true

        t.timestamps
    end
  end
end
