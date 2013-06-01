require_relative 'movie'
require_relative 'app_config'
require 'find'

class MovieFinder
  # This construct allows to define private class methods without having to
  # declare them with 'private_class_method'
  class << self

    def candidates_for_encoding
      # Makes method chaining possible
      return to_enum(__callee__) unless block_given?

      # select won't return all_movies array at the end of block like each
      all_movies.select do |movie_path|
        movie = Movie.new(movie_path)
        yield movie if movie.needs_encoding?
      end
    end

    def all_movies
      return to_enum(__callee__) unless block_given?

      Find.find(movies_root).select do |path|
        yield path if is_valid_movie_path?(path)
      end
    end

    def movies_root
      movies_root = File.expand_path AppConfig.movies_root
      raise "#{movies_root} does not exist!" unless Dir.exist? movies_root
      movies_root
    end

    def is_valid_movie_path?(path)
      fn = File.basename(path).downcase
      fn =~ valid_extensions_regex && !fn.include?("sample")
    end

    private

    def valid_extensions
      %w( mkv avi )
    end

    def valid_extensions_regex
      /\.(#{valid_extensions.join("|")})\z/
    end

  end
end
