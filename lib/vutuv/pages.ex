defmodule Vutuv.Pages do
	require Ecto.Query

	@max_page_items Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:max_page_items]

	def paginate(query, %{"page" => page}, total) do
		query
		|> Ecto.Query.limit(^@max_page_items)
		|> Ecto.Query.offset(^offset(total, @max_page_items, sanitize_page(page)))
	end

	def paginate(query, _, total) do
		paginate(query, %{"page" => 1}, total)
	end

	defp offset(total, limit, page) when (page*limit < total) do
		page*limit
	end

	defp offset(_, _, _), do: 0

	def total_pages(total) do
		div(total, @max_page_items) + 1
	end

	def page_list(%{"page" => page}, total) do
		gen_page_links(
			sanitize_page(page),
			total_pages(total))
	end

	def page_list(_, total) do
		page_list(%{"page" => 1}, total)
	end

	defp gen_page_links(page, max) when max > 1 do
		links = 
			for(num <- page-5..page+5) do
				cond do
					num > max -> nil
					num < 1 -> nil
					num == page -> page
					true -> page_link(num)
				end
			end
			|> Enum.filter(&(&1))
			|> Enum.join(" | ")
		"<div class=\"card__morelink card__morelink-border\">#{pre(page)}#{links}#{post(page, max)}</div>"
		|> Phoenix.HTML.raw
	end

	defp gen_page_links(_,_), do: ""

	defp pre(page) when page-5>1 do
		"... | "
	end

	defp pre(_), do: ""

	defp post(page, max) when page+5<max do
		" | ..."
	end

	defp post(_, _), do: ""

	defp page_link(page) do
		Phoenix.HTML.Link.link("#{page}", to: "?page=#{page}")
		|> Phoenix.HTML.safe_to_string
	end

	defp sanitize_page(page) when is_binary(page) do
		String.to_integer(page)
	end

	defp sanitize_page(page), do: page

end