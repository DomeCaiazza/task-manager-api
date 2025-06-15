module Api
  module V1
    class TasksController < ApiController
        before_action :authenticate_devise_api_token!
        before_action :set_user
        before_action :set_task, only: [ :show, :update, :destroy ]

        def index
            params[:q] ||= {}
            params[:q][:s] ||= [ "id desc" ]
            @q = @user.tasks.ransack(params[:q])
            @tasks = @q.result.page(params[:page]).per(params[:per_page])
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
            @user = current_devise_api_user
        end

        def set_task
            @task = @user.tasks.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Task not found" }, status: :not_found
        end

        def task_params
            params.require(:task).permit(:title, :description, :completed)
        end
    end
  end
end
