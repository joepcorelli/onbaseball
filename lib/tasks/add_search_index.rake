namespace :db do
  desc "Add search index for user display names"
  task add_search_index: :environment do
    puts "Adding search index for display_name field..."
    
    # Create a case-insensitive index for display_name searching
    User.collection.indexes.create_one(
      { display_name: "text" },
      { name: "display_name_text_index" }
    )
    
    puts "Search index added successfully!"
  end
end