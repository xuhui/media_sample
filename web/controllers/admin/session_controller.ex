defmodule ForEctoUpgrade.Admin.SessionController do
  use ForEctoUpgrade.Web, :admin_controller
  alias Ueberauth.Strategy.Helpers
  alias ForEctoUpgrade.Gettext

  plug Ueberauth, base_path: "/admin/auth"
  plug :check_logged_in

  def new(conn, _params) do
    render(conn, "new.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%Plug.Conn{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case AdminUserAuthService.auth_and_validate(auth, Repo) do
      {:ok, admin_user} ->
        conn
        |> put_flash(:info, "Signed in as #{admin_user.name}")
        |> put_session(:current_admin_user, admin_user)
        |> redirect(to: admin_page_path(conn, :index, Gettext.config[:default_locale])) |> halt
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not authenticate")
        |> redirect(to: admin_session_path(conn, :new)) |> halt
    end
  end

  def delete(conn, _params) do
    conn
      |> configure_session(drop: true)
      |> put_flash(:info, "admin signed out")
      |> redirect(to: admin_session_path(conn, :new)) |> halt
  end

  def check_logged_in(conn, _params) do
    if conn.request_path == admin_session_path(conn, :new) && admin_logged_in?(conn) do
      conn |> redirect(to: admin_page_path(conn, :index, Gettext.config[:default_locale])) |> halt
    else
      conn
    end
  end
end
