class StatisticsController < ApplicationController
  def index
    @word_counts = Page.word_counts
  end
end