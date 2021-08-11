# frozen_string_literal: true

class TasksController < ApplicationController
  def show
    task = Task.find_by_slug!(params[:slug])
    render status: :ok, json: { task: task }
  rescue ActiveRecord::RecordNotFound => errors
    render json: { errors: errors }, status: :not_found
  end

  def index
    tasks = Task.all
    render status: :ok, json: { tasks: tasks }
  end

  def create
    task = Task.new(task_params)
    if task.save
      render status: :ok, json: { notice: t("successfully_created") }
    else
      errors = task.errors.full_messages.to_sentence
      render status: :unprocessable_entity, json: { errors: errors }
    end
  end

  private

    def task_params
      params.require(:task).permit(:title)
    end
end

