class StatisticsController < ApplicationController
  def index
    @word_counts = WordCount.all
  end
end