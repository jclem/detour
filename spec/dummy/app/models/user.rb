class User < ActiveRecord::Base
  attr_accessible :email, :name
  acts_as_flaggable find_by: :email
  has_many :widgets
end
