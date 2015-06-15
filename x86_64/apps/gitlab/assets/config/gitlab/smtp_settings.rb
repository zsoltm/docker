# To enable smtp email delivery for your GitLab instance do next: 
# 1. Rename this file to smtp_settings.rb
# 2. Edit settings inside this file
# 3. Restart GitLab instance
#
if Rails.env.production?
  Gitlab::Application.config.action_mailer.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
    address: "{{SMTP_HOST}}",
    port: {{SMTP_PORT}},
    user_name: "{{SMTP_USER}}",
    password: "{{SMTP_PASSWORD}}",
    domain: "{{SMTP_DOMAIN}}",
    authentication: :{{SMTP_AUTH}},
    enable_starttls_auto: true,
    openssl_verify_mode: '{{SMTP_VERIFY}}' # See ActionMailer documentation for other possible options
  }
end
