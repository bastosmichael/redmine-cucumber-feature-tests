### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :login => "cpuller", :first_name => "Chesty", :last_name => "Puller", :email => "example@example.com",
    :password => "1qaz@WSX3edc$RV", :password_confirmation => "1qaz@WSX3edc$RV" }
end

def sign_up
  delete_user
  visit '/account/register'
  fill_in "user_login", :with => @visitor[:login]
  fill_in "user_password", :with => @visitor[:password]
  fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
  fill_in "user_firstname", :with => @visitor[:first_name]
  fill_in "user_lastname", :with => @visitor[:last_name]
  fill_in "user_mail", :with => @visitor[:email]
  click_button "Submit"
  find_user
end

def delete_user
  @user ||= User.where(:login => @visitor[:login]).first
  @user.destroy unless @user.nil?
end

def activate_user
  @user ||= User.where(:login => @visitor[:login]).first
  @user.activate
end

def find_user
  @user ||= User.where(:login => @visitor[:login]).first
end

def sign_in
  visit '/login'
  fill_in "username", :with => @visitor[:login]
  fill_in "password", :with => @visitor[:password]
  click_button "Login"
end

def approve_user
  find_user
  @user.status = User::STATUS_ACTIVE
  @user.save
end

def create_user
  create_visitor
  delete_user
  sign_up
  approve_user
end



### GIVEN ###
Given /^I am not logged in$/ do
  visit '/logout'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  click_link "Sign out"
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
  find_user
end

When(/^the user is approved$/) do
  approve_user
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "changeme123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong login$/ do
  @visitor = @visitor.merge(:login => "wrong_user_login")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link "My account"
  fill_in "user_firstname", :with => "Dan"
  fill_in "user_lastname", :with => "Daly"
  fill_in "user_mail", :with => "test@usmc.mil"
  click_button "Save"
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Sign out"
  page.should_not have_content "Sign in"
  page.should_not have_content "Register"
end

Then /^I should be signed out$/ do
  page.should have_content "Sign in"
  page.should have_content "Register"
  page.should_not have_content "Sign out"
end

Then /^I see a successful sign in message$/ do
  page.should have_content "Logged in as #{@visitor[:login]}"
end

Then /^I should see an admin approval needed message$/ do
  page.should have_content "Your account was created and is now pending administrator approval"
end

Then(/^I should be able to login$/) do
  sign_in
  page.should have_content "Logged in as #{@visitor[:login]}"
end


Then /^I should see an invalid email message$/ do
  page.should have_content "Email is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "Password is too short"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a signed out message$/ do
  page.should have_content "Sign in"
  page.should have_content "Register"
  page.should_not have_content "Sign out"
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid user or password"
end

Then /^I should see an account edited message$/ do
  page.should have_content "Account was successfully updated."
end