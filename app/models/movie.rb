require 'faraday'

class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  
  def self.find_in_tmdb(search_terms, api_key = '4c1f4838ca78f3a7fd9c670d6b53f409')
    
    target_url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{search_terms[:title]}&language=#{search_terms[:language]}&year=#{search_terms[:release_year]}"

    response = Faraday.get(target_url)
    parsed_response = JSON.parse(response.body)

    if parsed_response == nil || parsed_response.empty?
      return []
    else
      final_parsed = parsed_response["results"]
    end
    
    movies_list = final_parsed.map do |m_info|
      {
        title: m_info["title"],
        release_date: m_info["release_date"],
        rating: "R"
      }
    end
    movies_list.reject do |m|
      Movie.exists?(title: m[:title], release_date: m[:release_date])
    end
  end
end
