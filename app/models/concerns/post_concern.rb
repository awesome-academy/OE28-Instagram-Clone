module PostConcern
  extend ActiveSupport::Concern

  def update_post post_params
    post_params.except :images if post_params[:images].blank?
    update post_params
  end

  def extract_name_hashtags
    description.to_s.scan(/#\w+/).map{|name| name.gsub("#", "")}
  end

  def add_hashtags
    extract_name_hashtags.each do |name|
      hashtag = Hashtag.find_by name: name
      hashtag ||= Hashtag.create name: name

      hashtags << hashtag
    end
  end
end
