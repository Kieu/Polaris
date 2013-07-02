class BackgroundJobsController < ApplicationController

  before_filter :signed_in_user
  layout false
  # Stream a file that has already been generated and stored on disk
  def download_file
    job = BackgroundJob.find(params[:id])
    if current_user.id == job.user_id
      path = "#{Rails.root}/#{job.filepath}"
      send_file(path, filename: job.filename, :type => "text/csv; charset=utf-8")
    end
  end
  def download
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'download',:status =>'1').order("id desc")
    render "background_jobs/new"
  end
  def upload
    @jobs = BackgroundJob.where(:user_id => current_user.id,:type_view => 'upload',:status =>[1,2]).order("id desc")
    render "background_jobs/upload"
  end
  def index
    @jobs = BackgroundJob.all
    render "background_jobs/new"
  end
  def notification
    @jobs = BackgroundJob.where(:user_id => current_user.id,:status => '0').size
    render :text => @jobs
  end
  def inprogress
    @jobs = BackgroundJob.where(:user_id => current_user.id,:status => '0').order("id desc")
    render "background_jobs/inprogress"
  end
  def kill_job
    job = BackgroundJob.find(params[:id])
    if current_user.id==job.user_id
      #send signed for job
      BackgroundJob.destroy(params[:id])
     @raise_error = Resque::Plugins::Status::Hash.kill(job.job_id)
     render :text => @raise_error
    end
  end
end
