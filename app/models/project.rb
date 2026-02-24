# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Project < ApplicationRecord
  has_many :user_projects, class_name: "UserProject", foreign_key: "project_id", dependent: :destroy
  has_many :users, through: :user_projects, source: :user

  def to_t
    "#{title}"
  end

    def to_u
    "#{description}"
  end
end
