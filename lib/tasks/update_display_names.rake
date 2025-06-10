namespace :users do
  desc "Set display names for existing users"
  task set_display_names: :environment do
    User.where(display_name: nil).each do |user|
      user.update(display_name: user.email.split('@').first)
      puts "Updated display name for #{user.email}"
    end
  end
end