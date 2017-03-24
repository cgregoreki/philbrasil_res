# == Schema Information
#
# Table name: articles
#
#  id                    :integer          not null, primary key
#  author                :string(255)
#  title                 :text(65535)
#  year                  :integer
#  magazine              :string(255)
#  vol_number            :float(24)
#  translator            :string(255)
#  active                :boolean          default(TRUE)
#  times_visited         :integer
#  link                  :text(65535)
#  article_type          :string(255)
#  pub_company           :string(255)
#  pub_company_city      :string(255)
#  inside                :string(255)
#  article_personal_type :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  edition               :integer
#  issue                 :string(255)
#  first_page            :integer
#  last_page             :integer
#  keywords              :text(65535)
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
