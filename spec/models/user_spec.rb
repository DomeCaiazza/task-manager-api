require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a password shorter than 6 characters' do
      user = build(:user, password: '12345')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many tasks' do
      user = create(:user)
      expect(user.tasks).to be_empty
      
      task = create(:task, user: user)
      expect(user.tasks).to include(task)
    end

    it 'destroys associated tasks when deleted' do
      user = create(:user)
      task = create(:task, user: user)
      
      expect {
        user.destroy
      }.to change(Task, :count).by(-1)
    end
  end
end
