# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :load_task, only: [:show, :update]

  def show
    render status: :ok, json: { task: @task }
  end

  def update
    if @task.update(task_params)
      render status: :ok, json: { notice: "Successfully updated task." }
    else
      render status: :unprocessable_entity, json: { errors: @task.errors.full_messages.to_sentence }
    end
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

    def load_task
      @task = Task.find_by_slug!(params[:slug])
    rescue ActiveRecord::RecordNotFound => errors
      render json: { errors: errors }
    end
end

