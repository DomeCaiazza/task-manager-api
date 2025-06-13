module Api
  module V1
    class TasksController < ApiController
        before_action :set_user
        before_action :set_task, only: [:show, :update, :destroy]
        before_action :authorize_user, only: [:show, :update, :destroy]

        def index
            @tasks = @user.tasks.page(params[:page]).per(params[:per_page])
            render json: {
                tasks: @tasks,
                meta: {
                    current_page: @tasks.current_page,
                    total_pages: @tasks.total_pages,
                    total_count: @tasks.total_count
                }
            }, status: :ok
        end

        def show
            render json: @task, status: :ok
        end

        def create
            @task = @user.tasks.build(task_params)
            if @task.save
                render json: @task, status: :created
            else
                render json: { errors: @task.errors }, status: :unprocessable_entity
            end
        end

        def update
            if @task.update(task_params)
                render json: @task, status: :ok
            else
                render json: { errors: @task.errors }, status: :unprocessable_entity
            end
        end

        def destroy
            @task.destroy
            head :no_content
        end

        private

        def set_user
            @user = User.find(params[:user_id])
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'User not found' }, status: :not_found
        end

        def set_task
            @task = @user.tasks.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'Task not found' }, status: :not_found
        end

        def authorize_user
            unless @task.user_id == current_user.id
                render json: { error: 'Unauthorized' }, status: :unauthorized
            end
        end

        def task_params
            params.require(:task).permit(:title, :description, :completed)
        end
    end
  end
end