Wiki::Application.config.middleware.use OmniAuth::Builder do
  Rails.env == 'production' ? provider_suffix = '' : provider_suffix = '_DEV'
  provider :github, ENV['GITHUB_KEY' + provider_suffix], ENV['GITHUB_SECRET' + provider_suffix]
end
