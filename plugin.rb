# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory
  def self.watch_category!

    eresources_category = Category.find_by_slug("e-resources-committee")
    eresources_group = Group.find_by_name("eresources")

    unless eresources_category.nil? || eresources_group.nil?
      eresources_group.users.each do |user|
        watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], eresources_category.id) unless watched_categories.include?(eresources_category.id)
      end
    end

    digped_category = Category.find_by_slug("digital-pedagogy-committee")
    digped_group = Group.find_by_name("digped")

    return if digped_category.nil? || digped_group.nil?

    digped_group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], digped_category.id) unless watched_categories.include?(digped_category.id)
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
