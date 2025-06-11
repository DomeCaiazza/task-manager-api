module Api
  module V1
    class TasksController < ApiController
        def index
            @tasks = Task.page(params[:page]).per(params[:per_page])
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
            @task = Task.find(params[:id])
            render json: @task, status: :ok
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'Task not found' }, status: :not_found
        end

        def create
            @task = Task.new(task_params)
            if @task.save
                render json: @task, status: :created
            else
                render json: { errors: @task.errors }, status: :unprocessable_entity
            end
        end

        def update
            @task = Task.find(params[:id])
            if @task.update(task_params)
                render json: @task, status: :ok
            else
                render json: { errors: @task.errors }, status: :unprocessable_entity
            end
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'Task not found' }, status: :not_found
        end

        def destroy
            @task = Task.find(params[:id])
            @task.destroy
            head :no_content
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'Task not found' }, status: :not_found
        end

        private

        def task_params
            params.require(:task).permit(:title, :description, :completed)
        end
    end
  end
end