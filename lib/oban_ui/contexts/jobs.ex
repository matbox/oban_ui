defmodule ObanUi.Contexts.Jobs do
  @moduledoc """
  Context for Oban Jobs
  """
  import Ecto.Query, warn: false

  alias ObanUi.Contexts.Jobs.Job
  alias ObanUi.Repo

  def get!(id) do
    Repo.one(from j in Job, where: j.id == ^id)
  end

  @doc """
  Paginates, ordering if necessary
  """
  def paginate(params, order_by \\ [desc: :inserted_at]) do
    query = from(j in Job)

    query
    |> maybe_filter_by_state(params)
    |> order(order_by)
    |> Repo.paginate(params)
    |> Repo.prepare_page(order_by, params)
  end

  ######### Filtering

  defp maybe_filter_by_state(query, %{"state" => state}) when state in [nil, "", :all_but_completed] do
    from(j in query, where: j.state != ^"completed")
  end

  defp maybe_filter_by_state(query, %{"state" => "all"}), do: query

  defp maybe_filter_by_state(query, %{"state" => state}) do
    from(j in query, where: j.state == ^state)
  end

  defp maybe_filter_by_state(query, _), do: query

  ######### Ordering

  defp order(query, order_by), do:
    from(d in query, order_by: ^order_by)
end
