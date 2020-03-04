module UserHelper
  def gender user
    if user.gender == "female"
      Settings.user.gender_female
    elsif user.gender == "male"
      Settings.user.gender_male
    else
      nil
    end
  end
end
