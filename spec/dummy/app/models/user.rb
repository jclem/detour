class User < ActiveRecord::Base
  attr_accessible :email, :name
  acts_as_flaggable
end
