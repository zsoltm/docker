# To enable smtp email delivery for your GitLab instance do next: 
# 1. Rename this file to smtp_settings.rb
# 2. Edit settings inside this file
# 3. Restart GitLab instance
#
if Rails.env.production?
  Gitlab::Application.config.action_mailer.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
    address: "email.server.com",
    port: 456,
    user_name: "smtp",
    password: "123456",
    domain: "gitlab.company.com",
    authentication: :login,
    enable_starttls_auto: true,
    openssl_verify_mode: 'peer' # See ActionMailer documentation for other possible options
  }
end
