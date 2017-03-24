# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string(255)
#  email      :string(255)
#  message    :text(65535)
#

class Contact < ApplicationRecord

    attr_accessor :name, :email, :message

    validates :name,
    presence: true

    validates :email,
    presence: true

    validates :message,
    presence: true

end
