class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:edit, :update, :destroy]
  # GET /posts
  # GET /posts.json
  def index
    #@posts = Post.all
    @posts = Post.where("title ILIKE ?", "#{params[:search]}%")
                 .page(params[:page]).per(9)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])  
    respond_to do |format|
      format.html
      format.json { render json: @post }
      format.pdf do
        pdf = PostPdf.new(@post)
        send_data pdf.render, filename: "#{@post.title}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def new
    @post = current_user.posts.build
  end

  def edit
  end

  def create
    @user = current_user
    @post = @user.posts.build(post_params)
      if @post.save
        @subscribers = Subscriber.all
          if @subscribers != NIL
            @subscribers.each do |subscriber|
            SubscriberMailer.new_post(subscriber, @post).deliver
          end
        end
        redirect_to @post, notice: 'Post was successfully created.'
      else
        render :new
      end
    end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = current_user.posts.find_by(id: params[:id])
      redirect_to posts_path, notice: "Nie jesteś uprawniony do edycji tego postu" if @post.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:author, :description, :title, :image)
    end
    
end
