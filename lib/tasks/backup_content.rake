task :backup_content => :environment do
  # DO IT ONLY IN PROD ENVIRONMENT ON SERVER!
  print 'This action need to be done only on production web-server'
  return if Rails.env != "production"
  sure_phrase = "Yes, I'm sure"
  print "DO YOU REALLY WANT TO BACKUP ENTIRE WIKI_CONTENT INTO ? (type '#{sure_phrase}')"
  PageModule.backup
  # work with git
end
