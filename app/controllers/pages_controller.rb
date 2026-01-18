class PagesController < ApplicationController
  def app
    render :app, layout: "app"
  end
end
