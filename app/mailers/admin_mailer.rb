class AdminMailer < ApplicationMailer


  def permission_request_notification(admin, permission_request)
    @user = permission_request.user
    @permission_request = permission_request
    @admin = admin
    mail to: admin.email, subject: "Alice: new permission request"  
  end
  
end