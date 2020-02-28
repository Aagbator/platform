class CreateProjectSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :project_submissions do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :project, foreign_key: true, null: false
      # This has to be a float b/c there may be more factors in involved in a grade than
      # the points_available. E.g. 10 points available but 20 questions.
      t.float :points_received
      t.datetime :submitted_at
      t.datetime :graded_at
      t.timestamps
    end
  end
end
