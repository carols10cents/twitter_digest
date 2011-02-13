class DigestController < ApplicationController
  before_filter :login_required
  
  def index
    @tweets = client.home_timeline
  end

end
