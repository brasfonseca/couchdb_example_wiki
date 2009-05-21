class StatisticsController < ApplicationController
  def index
    @word_counts = db.view Page.word_counts
  end
end