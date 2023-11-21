class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Include Pagy headers automattically
  after_action { pagy_headers_merge(@pagy) if @pagy }
end
