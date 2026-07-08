defmodule DuskmoonStorybookWeb.Components.DataDisplayController do
  use DuskmoonStorybookWeb, :controller

  def accordion(conn, _params) do
    render(conn, :accordion, active_menu: "data-display-accordion")
  end

  def avatar(conn, _params) do
    render(conn, :avatar, active_menu: "data-display-avatar")
  end

  def badge(conn, _params) do
    render(conn, :badge, active_menu: "data-display-badge")
  end

  def card(conn, _params) do
    render(conn, :card, active_menu: "data-display-card")
  end

  def chat(conn, _params) do
    render(conn, :chat, active_menu: "data-display-chat")
  end

  def chip(conn, _params) do
    render(conn, :chip, active_menu: "data-display-chip")
  end

  def stat(conn, _params) do
    render(conn, :stat, active_menu: "data-display-stat")
  end

  def flash(conn, _params) do
    render(conn, :flash, active_menu: "data-display-flash")
  end

  def git_repository_header(conn, _params) do
    render(conn, :git_repository_header, active_menu: "data-display-git-repository-header")
  end

  def git_repository_nav(conn, _params) do
    render(conn, :git_repository_nav, active_menu: "data-display-git-repository-nav")
  end

  def git_file_tree(conn, _params) do
    render(conn, :git_file_tree, active_menu: "data-display-git-file-tree")
  end

  def git_blob_viewer(conn, _params) do
    render(conn, :git_blob_viewer, active_menu: "data-display-git-blob-viewer")
  end

  def git_commit_diff(conn, _params) do
    render(conn, :git_commit_diff, active_menu: "data-display-git-commit-diff")
  end

  def git_clone_box(conn, _params) do
    render(conn, :git_clone_box, active_menu: "data-display-git-clone-box")
  end

  def markdown(conn, _params) do
    render(conn, :markdown, active_menu: "data-display-markdown")
  end

  def pagination(conn, _params) do
    render(conn, :pagination, active_menu: "data-display-pagination")
  end

  def progress(conn, _params) do
    render(conn, :progress, active_menu: "data-display-progress")
  end

  def skeleton(conn, _params) do
    render(conn, :skeleton, active_menu: "data-display-skeleton")
  end

  def table(conn, _params) do
    render(conn, :table, active_menu: "data-display-table")
  end

  def timeline(conn, _params) do
    render(conn, :timeline, active_menu: "data-display-timeline")
  end

  def tooltip(conn, _params) do
    render(conn, :tooltip, active_menu: "data-display-tooltip")
  end

  def popover(conn, _params) do
    render(conn, :popover, active_menu: "data-display-popover")
  end

  def list(conn, _params) do
    render(conn, :list, active_menu: "data-display-list")
  end

  def collapse(conn, _params) do
    render(conn, :collapse, active_menu: "data-display-collapse")
  end
end
