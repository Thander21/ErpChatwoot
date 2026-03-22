class Enterprise::Api::V1::CustomContactsController < Api::V1::Accounts::BaseController
  def index
          page = params[:page].presence || 1
          contacts = Current.account.contacts.includes(:company).page(page)

          render json: {
            payload: contacts.map { |c| serialize_contact(c) },
            meta: {
              current_page: contacts.current_page,
              total_pages: contacts.total_pages,
              total_count: contacts.total_count
            }
          }
        end

        def update
          contact = Current.account.contacts.find(params[:id])
          if contact.update(contact_params)
            render json: { success: true, payload: serialize_contact(contact) }
          else
            render json: { success: false, errors: contact.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          contact = Current.account.contacts.find(params[:id])
          contact.destroy!
          render json: { success: true }
        end

        private

        def serialize_contact(c)
          {
            id: c.id,
            name: c.name,
            email: c.email,
            phone_number: c.phone_number,
            additional_attributes: c.additional_attributes,
            company_id: c.company_id,
            company: c.company ? c.company.as_json(only: [:id, :name, :description, :domain]) : nil,
            created_at: c.created_at,
            updated_at: c.updated_at
          }
        end

        def contact_params
          params.require(:contact).permit(
            :name, :email, :phone_number, :avatar, :identifier, :company_id,
            custom_attributes: {},
            additional_attributes: {}
          )
        end
end
