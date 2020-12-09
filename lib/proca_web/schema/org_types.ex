defmodule ProcaWeb.Schema.OrgTypes do
  @moduledoc """
  API for org entities
  """

  use Absinthe.Schema.Notation
  alias ProcaWeb.Resolvers
  alias ProcaWeb.Resolvers.Authorized

  object :org_queries do
    @desc "Organization api (authenticated)"
    field :org, :org do
      middleware(Authorized, access: [:org, by: [:name]])

      @desc "Name of organisation"
      arg(:name, non_null(:string))

      resolve(&Resolvers.Org.get_by_name/3)
    end
  end

  # MAIN TYPE

  object :org do
    @desc "Organization id"
    field :id, :integer
    @desc "Organisation short name"
    field :name, :string
    @desc "Organisation title (human readable name)"
    field :title, :string
    field :personal_data, non_null(:personal_data) do
      resolve(&Resolvers.Org.org_personal_data/3)
    end
    field :keys, non_null(list_of(non_null(:key))) do
      middleware Authorized, can?: :export_contacts
      arg :select, :select_key
      resolve(&Resolvers.Org.list_keys/3)
    end
    field :key, :key do
      middleware Authorized, can?: :export_contacts
      arg :select, non_null(:select_key)
      resolve(&Resolvers.Org.get_key/3)
    end

    # TODO:
    # field :public_keys, non_null(list_of(non_null(:string)))
    # field :users, non_null(list_of(:org_user))
    # field :services, non_null(list_of(:service))

    # field :personal_data, :personal_data
    #  field :contact_schema, :string
    #  field :email_opt_in, :boolean
    #  field :email_opt_in_template, :string

    # field :processing, :processing
    #  field :email_from, :string
    #  field :email_backend, :string
    #  field :template_backend, :string
    #
    #  field :custom_supporter_confirm, :boolean
    #  field :custom_action_confirm, :boolean
    #  field :custom_action_deliver, :boolean
    #
    #  field :sqs_deliver, :boolean

    @desc "List campaigns this org is leader or partner of"
    field :campaigns, list_of(:campaign) do
      arg :select, :select_campaign
      resolve(&Resolvers.Org.campaigns/3)
    end

    @desc "List action pages this org has"
    field :action_pages, list_of(:action_page) do
      arg :select, :select_action_page
      resolve(&Resolvers.Org.action_pages/3)
    end

    @desc "Action Page"
    field :action_page, :action_page do
      arg(:id, :integer)
      arg(:name, :string)
      resolve(&Resolvers.Org.action_page/3)
    end

    @desc "Get campaign this org is leader or partner of by id"
    field :campaign, :campaign do
      arg(:id, :integer)
      resolve(&Resolvers.Org.campaign_by_id/3)
    end
  end

  input_object :org_input do
    @desc "Name used to rename"
    field :name, :string

    @desc "Organisation title (human readable name)"
    field :title, :string

    @desc "Schema for contact personal information"
    field :contact_schema, :contact_schema

    @desc "Email opt in enabled"
    field :email_opt_in, :boolean

    @desc "Email opt in template name"
    field :email_opt_in_template, :string
  end


  object :org_mutations do
    field :add_org, type: :org do
      middleware Authorized

      arg :input, non_null(:org_input)

      resolve(&Resolvers.Org.add_org/3)
    end

    field :delete_org, type: :boolean do
      middleware Authorized, access: [:org, by: [:name]], can?: :org_owner
      @desc "Name of organisation"
      arg :name, non_null(:string)

      resolve(&Resolvers.Org.delete_org/3)
    end

    field :update_org, type: :org do
      middleware Authorized,
        access: [:org, by: [:name]],
        can?: [:change_org_settings]

      @desc "Name of organisation, used for lookup, can't be used to change org name"
      arg(:name, non_null(:string))
      arg(:input, non_null(:org_input))

      resolve(&Resolvers.Org.update_org/3)
    end

    field :join_org, type: :join_org_result do
      middleware Authorized
      arg :name, non_null(:string)
    end

    field :generate_key, type: :key_with_private do
      middleware Authorized,
        access: [:org, by: [name: :org_name]],
        can?: [:change_org_settings, :export_contacts]

      @desc "Name of organisation"
      arg :org_name, non_null(:string)
      arg :input, non_null(:gen_key_input)

      resolve(&Resolvers.Org.generate_key/3)
    end

    field :add_key, type: :key do
      middleware Authorized,
        access: [:org, by: [name: :org_name]],
        can?: [:change_org_settings, :export_contacts]

      @desc "Name of organisation"
      arg :org_name, non_null(:string)
      arg :input, non_null(:add_key_input)

      resolve(&Resolvers.Org.add_key/3)
    end

    @desc "A separate key activate operation, because you also need to add the key to receiving system before it is used"
    field :activate_key, type: :activate_key_result do
      middleware Authorized,
        access: [:org, by: [name: :org_name]],
        can?: [:change_org_settings, :export_contacts]

      arg :org_name, non_null(:string)
      @desc "Key id"
      arg :id, non_null(:integer)

      resolve(&Resolvers.Org.activate_key/3)
    end
  end

  # OTHER TYPES

  object :public_org do
    @desc "Organisation short name"
    field :name, :string

    @desc "Organisation title (human readable name)"
    field :title, :string
  end

  enum :contact_schema do
    value :basic
    value :popular_initiative
    value :eci
  end

  object :personal_data do
    @desc "Schema for contact personal information"
    field :contact_schema, non_null(:contact_schema)

    @desc "Email opt in enabled"
    field :email_opt_in, non_null(:boolean)

    @desc "Email opt in template name"
    field :email_opt_in_template, :string
  end

  @desc "Encryption or sign key with integer id (database)"
  object :key do
    field :id, non_null(:integer)
    field :public, non_null(:string)
    field :name, :string
    field :active, :boolean
    field :expired, :boolean
    field :expired_at, :date_time
  end

  object :key_with_private do
    field :id, non_null(:integer)
    field :public, non_null(:string)
    field :private, non_null(:string)
    field :name, :string
    field :active, :boolean
    field :expired, :boolean
    field :expired_at, :date_time
  end

  input_object :add_key_input do
    field :name, non_null(:string)
    field :public, non_null(:string)
  end

  input_object :gen_key_input do
    field :name, non_null(:string)
  end

  input_object :select_key do
    field :id, :integer
    field :active, :boolean
    field :public, :string
  end

  object :join_org_result do
    field :status, :status
  end

  object :activate_key_result do
    field :status, :status
  end
end
