class ReportBadArticle < ApplicationRecord
    nilify_blanks

    belongs_to :article
end
