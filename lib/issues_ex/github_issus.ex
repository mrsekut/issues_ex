defmodule IssuesEx.GithubIssues do
    require Logger
    @user_agent [{"User-agent", "Elixir dave@pragprog.com"}]
    @github_url Application.get_env(:issues, :github_url)

    def fetch(user, project) do
        Logger.info "Fetching user #{user}'s project #{project}'"
        issues_url(user, project)
        |> HTTPoison.get(@user_agent)
        |> handle_response
    end

    def issues_url(user, project) do
        "#{@github_url}/repos/#{user}/#{project}/issues"
    end

    def handle_response({ :ok, %{status_code: 200, body: body}}) do
        Logger.info "Successful response"
        Logger.debug fn -> inspect(body) end
        { :ok, Poison.Parser.parse!(body, %{}) }
    end

    def handle_response({ _, %{status_code: status, body: body }}) do
        Logger.error "Error #{status} returned"
        { :error, Poison.Parser.parse!(body, %{}) }
    end
end