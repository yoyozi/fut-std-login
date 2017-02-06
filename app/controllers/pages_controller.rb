class PagesController < ApplicationController


	  def about
	  end


	  def contact
	  	@contact = Contact.new
	  end

	  def home
	  	@articles = Article.last(5)
	  end



end