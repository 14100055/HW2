class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @tlite = nil
    @rlite = nil
    
    @all_ratings = Movie.all_ratings
    @movies = Movie.all
    @checked_ratings = @all_ratings

    if params[:sort_by].nil?
      params[:sort_by] = session[:sort_by]
    else
      session[:sort_by] = params[:sort_by]
    end
    
    if params[:commit].nil?
      params[:ratings] = session[:ratings]
    else
      session[:ratings] = params[:ratings]
    end

    if !params[:ratings].nil?
      @checked_ratings = params[:ratings].keys
      @movies = @movies.where(:rating => params[:ratings].keys)
    end

    if !params[:sort_by].nil?
      @movies = @movies.order(params[:sort_by])
      if params[:sort_by] == "title"
        @tlite = "hilite"
      elsif params[:sort_by] == "release_date"
        @rlite = "hilite"
      end
    end

  end
 
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def edits
  end
  
  def updates
    updated_movie = params[:movie]
    if @movie = Movie.find_by_title(updated_movie[:title_check])
      if updated_movie[:title] != "" && updated_movie[:rating] != "" && updated_movie[:release_date] != ""
        @movie.update_attributes!(movie_params)
        flash[:notice] = "#{@movie.title} was successfully updated."
      else
        flash[:notice] = "#{@movie.title} was not updated: all fields not entered."
      end
    else
      flash[:notice] = "#{updated_movie[:title_check]} was not found!"
    end
    redirect_to movies_path
  end

  def delete_title
    if params.has_key?(:movie)
      deleted_movie = params[:movie]
      if @movie = Movie.find_by_title(deleted_movie[:title])
        @movie.destroy
        flash[:notice] = "#{deleted_movie[:title]} was deleted!"
      else
        flash[:notice] = "#{deleted_movie[:title]} was not deleted!"
      end
      redirect_to movies_path
    end
  end

  def delete_rating
    if params.has_key?(:movie)
      deleted_movie = params[:movie]
      Movie.where(:rating => deleted_movie[:rating]).each do |movie|
        movie.destroy
      end
      flash[:notice] = "Movies with ratings \"#{deleted_movie[:rating]}\" were deleted!"
      redirect_to movies_path
    end
  end

end
