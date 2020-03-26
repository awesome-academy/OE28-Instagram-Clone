User.create!(email: "viethoang290111hust@gmail.com",
  username: "admin11",
  name: "Lê Việt Hoàng",
  password: "123456",
  password_confirmation: "123456",
  role: "admin"
)

User.create!(email: "viethoang29012hust@gmail.com",
  username: "viethoanglee",
  name: "Lê Việt Hoàng",
  password: "123456",
  password_confirmation: "123456",
  role: "admin"
)


User.create!(email: "viethoang29012hust@gmail.com",
  username: "viethoanglee",
  name: "Lê Việt Hoàng",
  password: "123456",
  password_confirmation: "123456",
)

28.times do |n|
  email = "viethoang29012hust-index#{n}@gmail.com"
  username = "viethoang#{n}"
  name = Faker::Name.name
  password = "123456"
  password_confirmation = "123456"
  User.create(
    email: email,
    username: username,
    name: name,
    password: password,
    password_confirmation: password_confirmation
  )
end

users = User.all
user = users.first
following = users[2..20]
followers = users[18..30]
following.each { |other_user| user.follow other_user }
followers.each { |other_user| other_user.follow user }

user.posts[1..5].each do |post| 
  followers.each do |other_user|
    like= other_user.bookmark_likes.build post_id: post.id, type_action: 0
    like.save
  end

  following.each do |other_user|
    comment=post.comments.build content: Faker::Lorem.sentence(word_count: 7)
    comment.user=other_user
    comment.save
  end
end

users = User.all
user = users.first
following = users[2..20]
followers = users[18..30]
following.each { |other_user| user.follow other_user }
followers.each { |other_user| other_user.follow user }

senders = User.all[2..5]
user_first = User.first
senders.each do |sender|
  notif = sender.active_notifications.build receiver_id: user_first.id, type_notif: 0
  notif.save
end
