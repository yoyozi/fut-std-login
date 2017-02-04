class PagesController < ApplicationController


	  def about
	  end


	  def contact
	  end

	  def home
	  	@articles = Article.last(5)
	  end



end