module Manage
  class OrganisationsController < BaseController
    load_and_authorize_resource :organisation
    before_action :set_organisation
    after_action :attach_files, only: :update

    def edit; end

    def update
      @organisation.update(organisation_params)
      respond_with :manage, @organisation, location: edit_manage_organisation_path
    end

    private

    def set_organisation
      @organisation = current_organisation
    end

    def attach_files
      terms_pdf,
      logo,
      privacy_statement_pdf = *organisation_params.slice(:terms_pdf, :logo, :privacy_statement_pdf).values

      @organisation.terms_pdf.attach(terms_pdf) if terms_pdf.present?
      @organisation.privacy_statement_pdf.attach(privacy_statement_pdf) if privacy_statement_pdf.present?
      @organisation.logo.attach(logo) if logo.present?
    end

    def organisation_params
      params.require(:organisation).permit(:name, :address, :booking_strategy_type, :invoice_ref_strategy_type,
                                           :esr_participant_nr, :message_footer, :logo,
                                           :privacy_statement_pdf, :terms_pdf, :iban, :delivery_method_settings_url,
                                           :representative_address, :contract_signature, :email)
    end
  end
end
