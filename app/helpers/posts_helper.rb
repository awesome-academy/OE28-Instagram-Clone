module PostsHelper
  def separate_lines description
    description.split "\n"
  end
  
  def separate_words line
    line.to_s.split " "
  end  
end
