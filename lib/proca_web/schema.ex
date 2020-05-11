defmodule ProcaWeb.Schema do
  use Absinthe.Schema
  alias ProcaWeb.Resolvers

  import_types ProcaWeb.Schema.DataTypes
  import_types ProcaWeb.Schema.InputTypes

  query do
    @desc "Get a list of campains"
    field :campaigns, list_of(:campaign) do
      @desc "Filter campaigns by title using LIKE format (% means any sequence of characters)"
      arg :title, :string
      @desc "Filter campaigns by name (exact match). If found, returns list of 1 campaign, otherwise an empty list"
      arg :name, :string
      @desc "Filter campaigns by id. If found, returns list of 1 campaign, otherwise an empty list"
      arg :id, :integer
      resolve &Resolvers.Campaign.list/3
    end

    @desc "Get action page"
    field :action_page, :action_page do
      @desc "Get action page by id."
      arg :id, :integer
      @desc "Get action page by url the widget is displayed on"
      arg :url, :string
      resolve &Resolvers.ActionPage.find/3
    end

    @desc "Organization api (authenticated)"
    field :org, :org do
      @desc "Name of organisation"
      arg :name, :string

      resolve &Resolvers.Org.find/3
    end
  end

  mutation do
    @desc "Adds a signature"
    field :add_signature, type: :id do
      @desc "ID of ActionPage of widget adding signature"
      arg :action_page_id, non_null(:id)
      @desc "Contact data"
      arg :contact, non_null(:contact_input)
      @desc "Signature action data"
      arg :action, :signature_extra_input
      @desc "GDPR communication opt"
      arg :privacy, non_null(:consent_input)
      @desc "Tracking codes (UTM_*)"
      arg :tracking, :tracking_input
      
      resolve &Resolvers.Contact.add_signature/3
    end

    @desc "Adds an action referencing contact data via contactRef"
    field :add_action, type: :id do
      arg :action_page_id, non_null(:id)
      @desc "Action data"
      arg :action, non_null(:action_extra_input)

      @desc "Contact reference"
      arg :contact_ref, :id

      @desc "Tracking codes (UTM_*)"
      arg :tracking, :tracking_input

      resolve &Resolvers.Action.add_action/3
    end

    @desc "Adds an action with contact data"
    field :add_action_contact, type: :id do
      arg :action_page_id, non_null(:id)
      @desc "Action data"
      arg :action, :action_extra_input
      @desc "GDPR communication opt"

      arg :contact, non_null(:contact_input)
      @desc "Signature action data"
      arg :privacy, non_null(:consent_input)

      @desc "Tracking codes (UTM_*)"
      arg :tracking, :tracking_input

      resolve &Resolvers.Action.add_action_contact/3
    end
  end

  # addSignature(action_page_id, details, tracking)

end
