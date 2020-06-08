require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @end_time = Time.now
    @start_time = params[:time].to_datetime
    @grid = params[:grid].split(" ")
    @attempt = params[:attempt]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def included?(attempt, grid)
    attempt.chars.all? { |letter| attempt.upcase.count(letter) <= grid.count(letter) }
  end

  def compute_score(time_taken, attempt)
    time_taken > 20.0 ? 0 : attempt.chars.length + (10 / time_taken).to_i
  end

  def english_word?(attempt)
    url = "http://wagon-dictionary.herokuapp.com/#{attempt}"
    data = JSON.parse(open(url).read)
    data["found"] == true
  end

  def score_and_message(attempt, grid, time_taken)
    if (attempt.chars.all? { |letter| attempt.upcase.count(letter) <= grid.count(letter) }) == false
      [0, "not an English word"]
    elsif included?(attempt.upcase, grid) == false
      [0, "sorry not in the grid"]
    else
      [compute_score(time_taken, attempt), "well done"]
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
    result[:score] = score_and_message(attempt, grid, result[:time]).first
    result[:message] = score_and_message(attempt, grid, result[:time]).last
    return result
  end

end
