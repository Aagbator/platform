class LessonsController < ApplicationController
  include DryCrud::Controllers::Nestable

  nested_resource_of GradeCategory

  # GET /lessons
  # GET /lessons.json
  def index
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
  end

end
