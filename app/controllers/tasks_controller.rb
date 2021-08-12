# frozen_string_literal: true

class TasksController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  before_action :authenticate_user_using_x_auth_token
  before_action :load_task, only: %i[show update destroy]
  before_action :ensure_authorized_update_to_restricted_attrs, only: %i[update]

  def index
    tasks = policy_scope(Task)
    pending_tasks = tasks.pending
    completed_tasks = tasks.completed
    render status: :ok, json: {
      tasks: { pending: pending_tasks, completed: completed_tasks }
    }
  end

  def create
    @task = Task.new(task_params.merge(creator_id: @current_user.id))
    authorize @task
    if @task.save
      render status: :ok,
             json: { notice: t("successfully_created", entity: "Task") }
    else
      errors = @task.errors.full_messages.to_sentence
      render status: :unprocessable_entity, json: { errors: errors }
    end
  end

  def show
    authorize @task
    comments = @task.comments.order("created_at DESC")
    task_creator = User.find(@task.creator_id).name
    render status: :ok, json: {
      task: @task, assigned_user: @task.user,
      comments: comments, task_creator: task_creator
    }
  end

  def update
    authorize @task
    if @task.update(task_params)
      render status: :ok, json: {}
    else
      render status: :unprocessable_entity,
             json: { errors: @task.errors.full_messages.to_sentence }
    end
  end

  def destroy
    authorize @task
    if @task.destroy
      render status: :ok, json: {}
    else
      render status: :unprocessable_entity,
             json: { errors: @task.errors.full_messages.to_sentence }
    end
  end

  private

    def task_params
      params.require(:task).permit(:title, :user_id, :progress)
    end

    def ensure_authorized_update_to_restricted_attrs
      is_editing_restricted_params = Task::RESTRICTED_ATTRIBUTES.any? { |a| task_params.key?(a) }
      is_not_owner = @task.creator_id != @current_user.id
      if is_editing_restricted_params && is_not_owner
        authorization_error
      end
    end

    def load_task
      @task = Task.find_by_slug!(params[:slug])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e }, status: :not_found
    end
end

