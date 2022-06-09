require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:percentage)}
    it {should validate_presence_of(:quantity_threshold)}
  end
end
