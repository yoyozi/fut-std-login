class PagesController < ApplicationController


	  def about
	  end


	  def contact
	  	@contact = Contact.new
	  end

	  def home
	  	if 
   			current_user
   			redirect_to articles_path
	  	end
	  	@articles = Article.last(5)
	  end



end