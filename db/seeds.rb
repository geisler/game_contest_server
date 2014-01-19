['all', Rails.env].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed.downcase}.rb"
  if File.exists?(seed_file)
    puts "****************** Seeding ******************"
    puts "*** Loading #{seed} seed data ***"
    require seed_file
  end
end
