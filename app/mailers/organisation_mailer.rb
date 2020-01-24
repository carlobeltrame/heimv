class OrganisationMailer < ApplicationMailer
  before_action :set_organisation
  before_action :set_delivery_method_options

  default from: -> { @delivery_method_settings[:from] || @organisation.email },
          reply_to: -> { @organisation.email },
          bcc: -> { @delivery_method_settings[:bcc] }

  def booking_message(message)
    message.attachments_for_action_mailer.each { |name, attachment| attachments[name] = attachment }

    mail(to: message.to, subject: message.subject, cc: message.cc) do |format|
      format.text { message.markdown.to_text }
      format.html { message.markdown.to_html }
    end
  end

  protected

  def set_organisation
    @organisation = params[:organisation]
  end

  def set_delivery_method_options
    @delivery_method_settings = @organisation.delivery_method_settings
    self.delivery_method = @delivery_method_settings.delivery_method
    try(@delivery_method_settings.settings_method_name, @delivery_method_settings.to_h)
  end
end
