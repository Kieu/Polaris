namespace :db do
  desc "Recreate database"
  task recreate: ["db:drop", "db:create", "db:migrate", "db:test:prepare"]
end
