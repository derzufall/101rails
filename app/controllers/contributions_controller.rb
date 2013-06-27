class ContributionsController < ApplicationController

  before_filter :authenticate_user!, :only => [:create]
  # TODO: load_and_authorize

  def show
    @contribution = Contribution.find(params[:id])
  end

  def index

    # last 10 contributions
    #@contributions = Contribution.where(:approved => true).desc(:created_at).limit(10)
    @contributions = Contribution.desc(:created_at).limit(10)

    @title = 'List of all contributions'

  end

  def analyze
    @contribution = Contribution.find(params[:id])
    @contribution.languages = params[:languages]
    @contribution.technologies = params[:technologies]
    @contribution.features = params[:features]
    @contribution.concepts = params[:concepts]
    @contribution.analyzed = true
    @contribution.save!
    #TODO: your contributin is analyzed!
    #mail(
    #    to: current_user.email,
    #    subject: '101companies | Analyzed contribution ' + @contribution.full_title,
    #    content: 'Your contribution is analyzed!'
    #)
    render nothing: true
  end


  def create

    @contribution = Contribution.new
    @contribution.url = params[:contrb_repo_url].first
    @contribution.title = params[:contrb_title]

    folder = params[:contrb_folder]
    puts folder
    if folder.empty?
      folder = '/'
    end
    @contribution.folder = folder

    @contribution.description = params[:contrb_description]
    @contribution.user = current_user
    @contribution.save

    # TODO: check page owning
    #page = Page.find_or_create_page 'Contribution:'+Page.unescape_wiki_url(@contribution.title)
    #page.users << current_user
    #page.save!
    #@contribution.page = page
    #@contribution.save

    begin
      # send request to matching service
      Mechanize.new.post 'http://worker.101companies.org/services/analyzeSubmission',
        {
          :url => @contribution.url,
          :folder => @contribution.folder,
          :name => @contribution.title,
          :backping => "http://141.26.95.189:3000/contribute/analyze/#{@contribution.id}"
        }.to_json,
        {'Content-Type' => 'application/json'}
    rescue
      flash[:error] = "Request on analyze service wasn't successful. Please retry it later"
    end

    flash[:notice] = "You have created new contribution. Please wait until it will be approved by gatekeepers."

    #TODO: send email to gatekeeper and contributor
    redirect_to  action: "index"

  end

  def new

    # if not logged in -> show intro
    if !current_user
      render 'contributions/login_intro'
    end

    # retrieve github login
    begin
      if current_user.github_name == ''
        agent = Mechanize.new
        resp = agent.get "https://api.github.com/legacy/user/email/#{current_user.email}"
        resp = JSON.parse resp.body
        current_user.github_name = resp["user"]["login"]
        current_user.save
      end
      # retrieve repos of user
      temp_repos = Github.repos.list user: current_user.github_name
      @user_github_repos = ''
      # create list for select tag
      temp_repos.each do |repo|
        @user_github_repos = @user_github_repos + '<option>' + repo.clone_url + '</option>'
      end
    rescue
      flash.now[:warning] = "We couldn't retrieve you github information, please try in 5 minutes"
      redirect_to '/contribute'
    end

  end

end
