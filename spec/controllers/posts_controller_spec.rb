require 'rails_helper'

RSpec.describe PostsController, type: :controller do

  let!(:posts) { create_list(:post, 5) }
  let(:user) {create(:user)}
  let(:subscriber) {create(:subscriber)}

  describe "GET #index" do

    let(:post) { create(:post) }

    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end

    it "returns a search posts" do
      post = create(:post, title: "graphic")
      get :index, params: { search: "graphi" }
      expect(assigns(:posts)).to eq [post]
    end
  end

  describe "GET #show" do

    let(:post) { create(:post) }

    it 'should success response' do
      get :show, params: { id: post.id }
      expect(response).to be_successful
    end

    it 'should render show page' do
      get :show, params: { id: post.id }
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    it 'requires authentication' do
      get :new
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'should success' do
      sign_in(user)
      get :new
      expect(response).to be_successful
    end

    it 'should render new page' do
      sign_in(user)
      get :new
      expect(response).to render_template(:new)
    end

    it 'should assign new post' do
      sign_in(user)
      get :new
      expect(assigns(:post)).to be_a_new(Post)
    end

    it "value is not valid" do
      sign_in(user)
      post = Post.new(title: nil)
      expect(post).to_not be_valid
    end
  end

  describe "POST #create" do

    it "should success create" do
      sign_in(user)
      post :create, params: { post: attributes_for(:post) }
      expect(response).to have_http_status(:found)
    end

    it "will set notice" do
      sign_in(user)
      post :create, params: { post: attributes_for(:post) }
      expect(flash[:notice]).to be_present
    end

    context "when invalid" do
      before {
        sign_in(user)
        post :create, params: { post: { title: "", description: "lololol", author: "ola" } }
      }

      it "will render new template" do
        expect(response).to render_template(:new)
      end
    end
  end


  describe "PUT #update" do
    let(:other_user) { create(:user) }
    let(:post) { create(:post, user: user) }
    let(:valid_params) { attributes_for(:post, title: 'test') }
    let(:invalid_params) { attributes_for(:post, title: '') }

    context 'when author user' do

      subject do
        put :update, params: { id: post.id, post: valid_params }
      end

      it 'updates requested post' do
        sign_in(user)
        subject
        post.reload
        expect(post.title).to eq('test')
       end
     end

    context 'when other user' do

      subject do
        put :update, params: { id: post.id, post: valid_params }
      end

      it 'not updates requested post' do
        sign_in(other_user)
        subject
        expect(response).to_not be_successful
      end
    end

    context 'when invalid' do

      subject do
        put :update, params: { id: post.id, post: invalid_params }
      end

      it "will render edit template" do
        sign_in(user)
        subject
        expect(response).to render_template(:edit)
      end
    end
  end
end