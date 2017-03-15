defmodule Probreport.Roulette do
  @percents [0.9, 0.95, 0.99]
  @sectors Exroul.Roulettes.Classic.list_vals
  @bets_lst (Enum.map(@sectors, &([&1])) ++ Exroul.Roulettes.Classic.list_props)
  @csv_header Probreport.make_csv_header(@percents)
  def generate do
    rounds = Enum.map(1..1_000_000, fn(_) -> Erlng.rand_at(@sectors) end)
    Enum.map(@bets_lst, fn(bet) ->
      Enum.map(rounds, &(Exroul.Roulettes.Classic.win(&1, bet)))
      |> Probreport.make_verbose_row("Fortuna bet #{ List.flatten([bet]) |> Enum.at(0) |> Maybe.maybe_to_string }", @percents)
    end)
    |> Csvex.encode(%{keys: @csv_header})
    |> (fn(data) -> File.write!("./fortuna_rtp.csv", data) end).()
  end
end
