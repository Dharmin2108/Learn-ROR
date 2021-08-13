# frozen_string_literal: true

require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @task = create(:task)
  end

  def test_values_of_created_at_and_updated_at
    user = build(:user)
    task = Task.new(title: "This is a test task", user: user)
    assert_nil task.created_at
    assert_nil task.updated_at

    task.save!
    assert_not_nil task.created_at
    assert_equal task.updated_at, task.created_at

    task.update!(title: "This is a updated task")
    assert_not_equal task.updated_at, task.created_at
  end

  def test_task_should_not_be_valid_without_user
    @task.user = nil
    assert_not @task.save
    assert_equal ["User must exist"], @task.errors.full_messages
  end

  def test_task_title_should_not_exceed_maximum_length
    @task.title = "a" * 100
    assert_not @task.valid?
  end

  def test_exception_raised
    assert_raises ActiveRecord::RecordNotFound do
      Task.find(SecureRandom.uuid)
    end
  end

  def test_task_count_increases_on_saving
    assert_difference ["Task.count"], 1 do
      create(:task)
    end
  end

  def test_task_should_not_be_valid_without_title
    @task.title = ""
    assert @task.invalid?
  end

  def test_task_slug_is_parameterized_title
    title = @task.title
    @task.save!
    assert_equal title.parameterize, @task.slug
  end

  def test_incremental_slug_generation_for_tasks_with_same_title
    duplicate_task = create(:task, title: @task.title)
    assert_equal "#{@task.slug}-2", duplicate_task.slug
  end

  def test_error_raised_for_duplicate_slug
    new_task = create(:task)
    assert_raises ActiveRecord::RecordInvalid do
      new_task.update!(slug: @task.slug)
    end

    error_msg = new_task.errors.full_messages.to_sentence
    assert_match t("task.slug.immutable"), error_msg
  end

  def test_updating_title_does_not_update_slug
    assert_no_changes -> { @task.reload.slug } do
      updated_task_title = "updated task tile"
      @task.update!(title: updated_task_title)
      assert_equal updated_task_title, @task.title
    end
  end

  def test_slug_index_to_be_reused_after_getting_deleted
    duplicate_task = create(:task, title: @task.title)
    assert_equal "#{@task.slug}-2", duplicate_task.slug

    duplicate_task.destroy
    duplicate_task_with_same_title = create(:task, title: @task.title)

    assert_equal "#{@task.slug}-2", duplicate_task_with_same_title.slug
  end
end

