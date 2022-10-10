defmodule ObanUi.DataPage do
  @moduledoc """
  Represents a page of data loaded from the DB
  """
  @required_keys [
    :page_number,
    :page_size,
    :entries,
    :total_pages,
    :total_entries,
    :ordered_by,
    :ordered_by_direction
  ]
  @optional_keys [
    :showing_soft_deleted?
  ]
  @keys @required_keys ++ @optional_keys

  @enforce_keys @required_keys
  defstruct @keys

  @type t() :: %__MODULE__{
          page_number: integer(),
          page_size: integer(),
          entries: list(),
          total_pages: integer(),
          total_entries: integer(),
          ordered_by: String.t(),
          ordered_by_direction: String.t(),
          showing_soft_deleted?: boolean()
        }

  def from_scrivener(
        %Scrivener.Page{} = page,
        %{ordered_by: _, ordered_by_direction: _} = params
      ) do
    page
    |> Map.take([:page_number, :page_size, :entries, :total_pages, :total_entries])
    |> Map.merge(params)
    |> then(&struct!(__MODULE__, &1))
  end
end
