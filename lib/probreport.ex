defmodule Probreport do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Probreport.Worker.start_link(arg1, arg2, arg3)
      # worker(Probreport.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Probreport.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defstruct length: nil,
            mean: nil,
            std_dev: nil,
            # maps like %{90 => x, 95 => y, 99 => z}
            conf_half_ranges: %{},
            conf_min: %{},
            conf_max: %{}

  def make_raw(lst = [_|_], conf_precents) when is_list(conf_precents) do
    acc = %Probreport{
      length: length(lst),
      mean: Statistics.mean(lst),
      std_dev: Statistics.stdev(lst),
    }
    Enum.reduce(conf_precents, acc, fn(percent, acc = %Probreport{length: lstlen, mean: mean, std_dev: std_dev, conf_half_ranges: conf_half_ranges = %{}, conf_min: conf_min = %{}, conf_max: conf_max = %{}}) ->
      percent = Maybe.to_float(percent)
      true = is_float(percent) and (percent > 0) and (percent < 1)
      delta = :erlmath.qnorm_nif(percent + ((1 - percent) / 2)) * (std_dev / Statistics.Math.sqrt(lstlen))
      %Probreport{acc | conf_half_ranges: Map.put(conf_half_ranges, percent, delta), conf_min: Map.put(conf_min, percent, (mean - delta)), conf_max: Map.put(conf_max, percent, (mean + delta))}
    end)
  end

end
