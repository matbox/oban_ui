defmodule ObanUi.Live.Components.Pagination do
  @moduledoc """
    Pagination utils
  """
  use Surface.LiveComponent

  prop view, :module, required: true
  prop data, :struct, required: true
  prop page_params, :map, default: %{}

  @impl true
  def render(%{data: data} = assigns) do
    page_record_count = Enum.count(data.entries)
    first = (data.page_number - 1) * data.page_size
    last = first + page_record_count
    has_previous = data.page_number > 1
    has_next = data.page_number < data.total_pages
    prev_page = data.page_number - 1
    next_page = data.page_number + 1

    assigns = assign(assigns, :page_record_count, page_record_count)

    ~F"""
    <div class="flex flex-col items-center mt-4 mb-4" id={@id}>
      {#if assigns.page_record_count == 0}
        <div>No entries to display</div>
      {#else}
        <div>
          Displaying <b>{first + 1}&nbsp;-&nbsp;{last}</b> records of <b>{data.total_entries}</b> in total
        </div>
        <div class="mt-2">
          <ul class="flex justify-center align-middle">
            <li>
              <button
                class="btn btn-primary justify-center m-1 pl-1 pr-1"
                disabled={!has_previous}
                phx-value-page={prev_page}
                :on-click="paginate"
              >
                &lt;
                &nbsp;Previous
              </button>
            </li>
            <li>
              <button
                class="btn btn-primary justify-center m-1 pl-1 pr-1"
                disabled={!has_next}
                phx-value-page={next_page}
                :on-click="paginate"
              >
                Next&nbsp;
                &gt;
              </button>
            </li>
          </ul>
        </div>
      {/if}
    </div>
    """
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, %{assigns: %{view: view, page_params: existing_params}} = socket) do
    new_params = Map.merge(%{page: page}, existing_params)
    {:noreply, socket
    |> push_patch(to: routes().live_path(socket, view, new_params), replace: true)}
  end

  defp routes, do: Application.get_env(:oban_ui, :routes)
end
