class VisualTestsController < ApplicationController
  def colorscheme
    flash[:success] = "Success. This is a successful message."
    flash[:info] = "Info. This is an informational message."
    flash[:warning] = "Warning. This is a warning message."
    flash[:danger] = "Danger Will Robinson. This is a dangerous message."
  end
end
