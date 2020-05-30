defmodule Proca.Field do
  use Ecto.Schema
  import Ecto.Changeset
  alias Proca.Field

  schema "fields" do
    field :key, :string
    field :value, :string
    belongs_to :action, Proca.Action
  end


  def changesets(custom_fields) when is_list(custom_fields) do
    custom_fields
    |> Enum.map(fn cf -> changeset(cf) end)
  end

  def changeset(attr = %{key: _key, value: _value}) do
    %Field{}
    |> cast(attr, [:key, :value])
  end
end
