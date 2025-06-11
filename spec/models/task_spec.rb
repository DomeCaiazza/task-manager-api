require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it 'is valid with a title' do
      task = Task.new(title: 'Test Task')
      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = Task.new(title: nil)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end
  end

  describe 'pagination' do
    it 'paginates per 10 items' do
      expect(Task.default_per_page).to eq(10)
    end
  end
end
