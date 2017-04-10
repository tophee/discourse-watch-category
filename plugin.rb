# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.4
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory

  def self.watch_category!
    groups_cats = {
      # "group" => ["category", "another-top-level-category", ["parent-category", "sub-category"] ],
      "GMSS.registered" => [ ["research", "gmss-logistics"], ["research", "symposium"] ],
      "GMSS.interested" => [ ["research", "symposium"] ],
      # "everyone" makes every user watch the listed categories
      # "everyone" => [ "announcements" ]
    }
    
    # levels: :watching :watching_first_post etc.
    # level = :watching_first_post
    
    groups_cats.each do |group_name, cats|
      cats.each do |cat_slug|

        # If a category is an array, the first value is treated as the top-level category and the second as the sub-category
        if cat_slug.respond_to?(:each)
          category = Category.find_by_slug(cat_slug[1], cat_slug[0])
        else
          category = Category.find_by_slug(cat_slug)
        end
        group = Group.find_by_name(group_name)

        unless category.nil? || group.nil?
          if group_name == "everyone"
            User.all.each do |user|
              watched_categories = CategoryUser.lookup(user, :watching_first_post).pluck(:category_id)
              CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching_first_post], category.id) unless watched_categories.include?(category.id)
            end
          else
            group.users.each do |user|
              watched_categories = CategoryUser.lookup(user, :watching_first_post).pluck(:category_id)
              CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching_first_post], category.id) unless watched_categories.include?(category.id)
            end
          end
        end

      end
    end

  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 6.hours

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
