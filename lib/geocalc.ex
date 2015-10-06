defmodule Geocalc do
  @earth_radius 6_371_000

  @moduledoc """
  Calculate distance, bearing and more between Latitude/Longitude points.
  """

  @doc """
  Calculates distance between 2 points.
  Return distance in meters.

  ## Example
      iex> berlin = [52.5075419, 13.4251364]
      iex> paris = [48.8588589, 2.3475569]
      iex> Geocalc.distance_between(berlin, paris)
      878327.4291149472
  """
  def distance_between([point_1_lat, point_1_lng], [point_2_lat, point_2_lng]) do
    point_1_lat_rad = radian(point_1_lat)
    point_2_lat_rad = radian(point_2_lat)
    diff_lat = radian(point_2_lat - point_1_lat)
    diff_lng = radian(point_2_lng - point_1_lng)
    a = :math.sin(diff_lat / 2) * :math.sin(diff_lat / 2) + :math.cos(point_1_lat_rad) * :math.cos(point_2_lat_rad) * :math.sin(diff_lng / 2) * :math.sin(diff_lng / 2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius * c
  end

  def radian(lat_or_lng) do
    lat_or_lng * :math.pi / 180
  end
end