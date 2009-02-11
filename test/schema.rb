ActiveRecord::Schema.define(:version => 0) do
  create_table :taggable_models do |t|
    t.string  :title
  end

  create_table :tags do |t|
    t.string :name
    t.string :namespace
    t.string :predicate
    t.string :value
    t.datetime :created_at
  end

  create_table :taggings do |t|
    t.integer :tag_id
    t.string  :taggable_type
    t.integer :taggable_id
    t.datetime :created_at
  end
end
