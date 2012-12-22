require 'spec_helper'

describe CommentHelper do
  before(:each) do
    @foreign_request = FactoryGirl.create :request

    @user1 = FactoryGirl.create :user
    @user2 = FactoryGirl.create :user

    @comment = FactoryGirl.create :comment
    @comment.content = content
  end

  describe 'escape' do
    let (:content) { '<html>' }

    it 'should escape html in the comment content' do
      escape(@comment.content).should eq('&lt;html&gt;')
    end

    it 'should return an html_safe string to prevent escaping' do
      escape(@comment.content).html_safe?.should be_true
    end
  end

  describe 'embolden_mentions' do
    context 'with a valid mention' do
      let(:content) { "@#{@user1.username} can you talk to @#{@user2.username}?" }

      it 'should wrap mentions in strong tags' do
        embolden_mentions(@comment.content).should eq("<strong>@#{@user1.username}</strong> can you talk to <strong>@#{@user2.username}</strong>?")
      end
    end

    context 'with an invalid mention' do
      let(:content) { "@invalid can you talk to @invalid2?" }

      it 'should not wrap mentions in strong tags' do
        embolden_mentions(@comment.content).should eq("@invalid can you talk to @invalid2?")
      end
    end

    context 'without any mentions' do
      let(:content) { "I'm working on this right now." }

      it 'should not change the content' do
        embolden_mentions(@comment.content).should eq("I'm working on this right now.")
      end
    end
  end

  describe 'link_references' do
    context 'with a valid reference' do
      let(:content) { "This issue is related to ##{@foreign_request.id}." }

      it 'should insert full URL links' do
        link_references(@comment.content).should eq("This issue is related to <a href=\"#{request_url(@foreign_request)}\">##{@foreign_request.id}</a>.")
      end
    end

    context 'with an invalid reference' do
      let(:content) { "This issue is related to #asdf." }

      it 'should not insert links' do
        link_references(@comment.content).should eq(@comment.content)
      end
    end

    context 'without any references' do
      let(:content) { "This issue is related to another." }

      it 'should not change the content' do
        link_references(@comment.content).should eq(@comment.content)
      end
    end
  end
end
