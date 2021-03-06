class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  def self.role_options
    ['admin', 'editor', 'guest', 'deprecated']
  end

  field :email,          :type => String
  field :role,           :type => String, :default => "guest"
  field :name,           :type => String

  # github data
  field :github_name,    :type => String
  field :github_avatar,  :type => String, :default => "http://www.gravatar.com/avatar"
  field :github_token,   :type => String
  field :github_uid,     :type => String

  has_many :old_wiki_users
  has_many :page_changes
  has_and_belongs_to_many :pages, :class_name => 'Page', :inverse_of => :users
  has_many :contribution_pages, :class_name => 'Page', :inverse_of => :contributor

  validates_uniqueness_of :email
  validates_uniqueness_of :github_uid

  validates_presence_of :name, :email, :github_uid, :github_token, :github_name

  attr_accessible :role, :page_ids, :old_wiki_user_ids, :contribution_page_ids

  def populate_data(omniauth)
    self.email = omniauth['info']['email']
    self.name = omniauth['info']['name']
    self.github_name = omniauth['info']['nickname']
    self.github_avatar = omniauth['info']['image']
    self.github_token = omniauth['credentials']['token']
    self.github_uid = omniauth['uid']
  end

end
