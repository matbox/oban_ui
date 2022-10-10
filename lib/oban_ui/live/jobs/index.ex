defmodule ObanUi.Live.Jobs.Index do
  @moduledoc """
  Jobs LiveView
  """
  use Surface.LiveView

  alias Surface.Components.Form

  alias ObanUi.Contexts.Jobs
  alias ObanUi.Live.Components.Pagination

  data paginated_data, :struct
  data params, :map
  data selected_job, :struct

  @impl true
  def handle_params(params, _session, socket) do
    {:noreply, assign(socket,
    paginated_data: paginate_entries(params),
    params: params,
    selected_job: nil)}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <.selected_job_drawer job={@selected_job} />
      <div class="flex flex-col flex-gap p-5">
        <.filters paginated_data={@paginated_data} params={@params} />
        <.table paginated_data={@paginated_data} params={@params} />
      </div>
    </div>
    """
  end

  def filters(assigns) do
    ~F"""
    <Form for={:filters} change="filter">
      <div class="flex flex-row flex-gap items-center">
        <Form.Label>State:</Form.Label>
        <Form.Select class="inline" name={:state} options={state_options()} selected={@params["state"]} />
      </div>
    </Form>
    """
  end

  def table(assigns) do
    ~F"""
    <div>
      <table class="table">
        <thead>
          <th class="px-4 py-3">Worker</th>
          <th class="px-4 py-3">Attempt</th>
          <th class="px-4 py-3">Status</th>
          <th class="px-4 py-3">Date</th>
          <th class="px-4 py-3"></th>
        </thead>
        <tbody>
          {#for job <- @paginated_data.entries}
            <tr>
              <td class="px-4 py-3 border">
                <div>
                  <p class="font-semibold text-black">
                    <span class="font-normal text-gray-600">#{job.id}</span> {job.worker}
                  </p>
                  <p class="text-xs text-gray-600">@{job.attempted_by}::{job.queue}</p>
                  <p class="text-xs text-gray-600 truncate">{job.args |> inspect |> ObanUI.Truncate.truncate(length: 90)}</p>
                </div>
              </td>
              <td class="px-4 py-3 text-ms font-semibold border">{job.attempt}/{Map.get(job, :max_attempts, 20)}</td>
              <td class="px-4 py-3 text-xs border">
                <span class={"px-2 py-1 font-semibold leading-tight #{state_classes(job.state)} rounded-sm"}>
                  {job.state}
              </span>
              </td>
              <td class="px-4 py-3 text-sm border">{ObanUI.Timeago.time_ago_in_words(job.inserted_at)} ago</td>
              <td>
                <button class="btn btn-secondary rounded-full text-xs"
                  :on-click="show_job"
                  phx-value-id={job.id}>?</button>
              </td>
            </tr>
          {/for}
        </tbody>
      </table>
      <Pagination id="oban-jobs-pagination" data={@paginated_data} view={__MODULE__} page_params={@params} />
    </div>
    """
  end

  def selected_job_drawer(%{job: nil} = assigns), do: ~F""
  def selected_job_drawer(assigns) do
    ~F"""
    <div class="absolute right-0 w-1/2 h-screen z-50 bg-white border-l-4 border-accent p-5 flex flex-col flex-gap"
      phx-click-away="hide_job">
      <div>
        <button class="btn btn-accent rounded-md p-2 m-0 items-center justify-center text-xs"
          :on-click="hide_job">Close</button>
      </div>
      <div><span class="font-normal text-gray-600">#{@job.id}</span> {@job.worker}</div>
        <div class="flex flex-row flex-gap">
          <div class="font-bold">Queue</div>
          <div>{@job.queue}</div>
        </div>
      <div class="px-4 py-3 text-xs border">
        <div class="flex flex-row flex-gap items-center">
          <div class="font-semibold">Attempts {@job.attempt}/{Map.get(@job, :max_attempts, 20)}</div>
          <span class={"px-2 py-1 font-semibold leading-tight #{state_classes(@job.state)} rounded-sm"}>
            {@job.state}
          </span>
          <div>{ObanUI.Timeago.time_ago_in_words(@job.inserted_at)} ago</div>
        </div>
      </div>
      <div class="font-bold">Arguments:</div>
      <div class="text-xs text-gray-600">{inspect(@job.args)}</div>
    </div>
    """
  end

  @impl true
  def handle_event("filter", event, %{assigns: %{params: existing_params}} = socket) do
    new_params = event
    |> Map.take(["state"])
    |> then(& Map.merge(existing_params, &1))
    {:noreply, socket
      |> assign(:params, new_params)
      |> push_patch(to: routes().live_path(socket, __MODULE__, new_params), replace: true)}
  end

  @impl true
  def handle_event("hide_job", _event, socket), do: {:noreply, assign(socket, :selected_job, nil)}

  @impl true
  def handle_event("show_job", %{"id" => id}, socket) do
    job = Jobs.get!(id)
    {:noreply, assign(socket, :selected_job, job)}
  end

  def paginate_entries(params) do
    # First call from mount will not have order information
    params =
      params
      |> Map.put_new(:order_by_key, "inserted_at")
      |> Map.put_new(:order_by_direction, "asc")

    # If no state is being filtered, remove completed by default
    params = if Map.get(params, "state", nil) do
      params
    else
      Map.put(params, "state", :all_but_completed)
    end

    Jobs.paginate(params, [
      {String.to_existing_atom(params.order_by_direction), String.to_existing_atom(params.order_by_key)}
    ])
  end

  def state_classes(state) do
    case state do
      "available" -> "text-green-700 bg-green-100"
      "scheduled" -> "text-orange-700 bg-gray-100"
      "executing" -> "text-orange-700 bg-gray-100"
      "retryable" -> "text-orange-700 bg-gray-100"
      "completed" -> "text-green-700 bg-green-100"
      "cancelled" -> "text-red-700 bg-red-100"
      "discarded" -> "text-red-700 bg-red-100"
    end
  end

  def state_options do
    [
      {"-", nil},
      {"all", "all"},
      {"available", "available"},
      {"scheduled", "scheduled"},
      {"executing", "executing"},
      {"retryable", "retryable"},
      {"completed", "completed"},
      {"cancelled", "cancelled"},
      {"discarded", "discarded"}
    ]
  end

  defp routes, do: Application.get_env(:oban_ui, :routes)
end
