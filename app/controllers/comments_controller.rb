class CommentsController < ApplicationController
	
  def new
  @post = Post.find(params[:post_id])
  @comment = Comment.new
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(params[:comment].permit(:comment, :body))
    redirect_to post_path(@post)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  def comment_params
    params.require(:comment).permit(:comment, :body)
  end
  
end