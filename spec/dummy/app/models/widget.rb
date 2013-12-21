class Widget < ActiveRecord::Base
  attr_accessible :name
  acts_as_flaggable
  belongs_to :user
end
