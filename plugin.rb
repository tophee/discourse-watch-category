# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan
# url: https://github.com/discourse/discourse-watch-category-mcneel

module ::WatchCategory

  def self.watch_by_group(category_slug, group_name)
    category = Category.find_by_slug(category_slug)
    group = Group.find_by_name(group_name)

    return if category.nil? || group.nil?

    group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id)
      # Jared Needell's code
      # CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id) || user.staged
    end
  end

  def self.watch_category!
    WatchCategory.watch_by_group("digital-pedagogy-committee", "digped")
    WatchCategory.watch_by_group("e-resources-committee", "eresources")
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      # every 1.day
      # every 1.minute
      every 6.hours

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
