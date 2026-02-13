# == Schema Information
#
# Table name: skills
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Skill < ApplicationRecord
  belongs_to :user
  
  has_many :user_skills, class_name: "UserSkill", foreign_key: "skill_id", dependent: :destroy
  has_many :users, through: :user_skills, source: :user
end
