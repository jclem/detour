require "spec_helper"

class User < ActiveRecord::Base
  include ActiveRecord::Rollout::Flaggable
end

describe ActiveRecord::Rollout::Flaggable do
  subject { User.new }
  it { should have_many :flags }
  it { should have_many :rollouts }
end
