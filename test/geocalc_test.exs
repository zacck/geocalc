defmodule GeocalcTest do
  use ExUnit.Case
  doctest Geocalc

  test "calculates distance between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.distance_between(point_1, point_2), 968_853.5, 0.05
  end

  test "returns true when point is within a given radius from the circle center" do
    center = [18.2208, 66.5901]
    point = [18.4655, 66.1057]
    assert Geocalc.within?(170_000, center, point)
  end

  test "returns true when radius is 0 and the point equals the center point" do
    center = [18.2208, 66.5901]
    assert Geocalc.within?(0, center, center)
  end

  test "returns false when radius is 0 and point does not equal center point" do
    center = [18.2208, 66.5901]
    point = [18.4655, 66.1057]
    refute Geocalc.within?(0, center, point)
  end

  test "returns false when point is not wihtin a given radius from the circle center" do
    center = [18.2208, 66.5901]
    point = [52.5075419, 13.4251364]
    refute Geocalc.within?(170_000, center, point)
  end

  test "returns false when radius is negative" do
    center = [18.2208, 66.5901]
    point = [52.5075419, 13.4251364]
    refute Geocalc.within?(-170_000, center, point)
  end

  test "calculates distance between Minsk and London" do
    minsk = %{lat: 53.8838884, lon: 27.5949741}
    london = %{lat: 51.5286416, lon: -0.1015987}
    assert_in_delta Geocalc.distance_between(minsk, london), 1_872_028.5, 0.05
  end

  test "calculates bearing between two points" do
    point_1 = [50.0663889, -5.7147222]
    point_2 = [58.6438889, -3.07]
    assert_in_delta Geocalc.bearing(point_1, point_2), 0.159170, 0.000001
  end

  test "calculates bearing between Minsk and London" do
    minsk = %{latitude: 53.8838884, longitude: 27.5949741}
    london = %{latitude: 51.5286416, longitude: -0.1015987}
    assert_in_delta Geocalc.bearing(minsk, london), -1.513836, 0.000001
  end

  test "returns destination point between two points in direction to second point" do
    point_1 = [1.234, 2.345]
    point_2 = [3.654, 4.765]
    distance = 1_000
    brng = Geocalc.bearing(point_1, point_2)
    {:ok, point_3} = Geocalc.destination_point(point_1, brng, distance)
    assert_in_delta Geocalc.distance_between(point_3, [1.2403670648864074, 2.3513527343464733]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns destination point in pacific ocean near Japan" do
    point_1 = %{lat: 46.118942, lng: 150.402832}
    point_2 = %{lat: 21.913108, lng: -160.193712}
    distance = 1_178_348
    {:ok, point_3} = Geocalc.destination_point(point_1, point_2, distance)
    assert_in_delta Geocalc.distance_between(point_3, [42.64962243973242, 164.43934677825277]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns destination point in pacific ocean near Hawaii" do
    point_1 = {46.118942, 150.402832}
    point_2 = {21.913108, -160.193712}
    distance = 4_178_348
    {:ok, point_3} = Geocalc.destination_point(point_1, point_2, distance)
    assert_in_delta Geocalc.distance_between(point_3, [27.939238854720823, -167.5615280845497]), 0, 0.0005
    actual_distance = Geocalc.distance_between(point_3, point_1)
    assert_in_delta actual_distance, distance, 0.0005
  end

  test "returns intersection point" do
    point_1 = [51.8853, 0.2545]
    bearing_1 = Geocalc.degrees_to_radians(108.56)
    point_2 = [49.0034, 2.5735]
    bearing_2 = Geocalc.degrees_to_radians(32.47)
    {:ok, point_3} = Geocalc.intersection_point(point_1, bearing_1, point_2, bearing_2)
    assert point_3 == [50.90673507027868, 4.509919730256895]
  end

  test "all roads lead to Rome" do
    milan = {45.4628328, 9.1076929}
    naples = {40.8536668, 14.2079876}
    rome = {41.9102415, 12.3959161}
    {:ok, point_3} = Geocalc.intersection_point(milan, rome, naples, rome)
    assert_in_delta Geocalc.distance_between(point_3, rome), 0, 0.0005
  end

  test "returns error message if intersection point not found" do
    minsk = %{lat: 53.8838884, lon: 27.5949741}
    bearing = Geocalc.degrees_to_radians(0)
    {:error, msg} = Geocalc.intersection_point(minsk, bearing, minsk, bearing)
    assert msg == "No intersection point found"
  end

  test "crashes with ArithmeticError" do
    point_1 = %{lat: 30, lon: 0}
    point_2 = %{lat: 60, lon: 0}
    bearing = Geocalc.degrees_to_radians(90)
    {:error, msg} = Geocalc.intersection_point(point_1, bearing, point_2, bearing)
    assert msg == "No intersection point found"
  end

  test "returns error message for two perpendicular destinations" do
    point = %{lat: 0, lon: 0}
    bearing_1 = Geocalc.degrees_to_radians(0)
    bearing_2 = Geocalc.degrees_to_radians(90)
    {:error, msg} = Geocalc.intersection_point(point, bearing_1, point, bearing_2)
    assert msg == "No intersection point found"
  end

  test "returns a bounding box given a point and a radius in meters" do
    point = [52.5075419, 13.4251364]
    radius = 10_000
    assert Geocalc.bounding_box(point, radius) == [[52.417520954378574, 13.277235453275123], [52.59756284562143, 13.573037346724874]]
  end

  test "returns geographic center point" do
    assert Geocalc.geographic_center([[0, 0], [0, 1]]) == [0.0, 0.5]
    assert Geocalc.geographic_center([[0, 0], [0, 1], [0, 2]]) == [0.0, 1.0]
  end

  test "returns max latitude" do
    bearing_1 = Geocalc.degrees_to_radians(0)
    bearing_2 = Geocalc.degrees_to_radians(90)
    assert Geocalc.max_latitude([0, 0], bearing_1) == 90.0
    assert Geocalc.max_latitude([0, 0], bearing_2) == 0.0
  end

  test "returns cross track distance to point" do
    point_1 = %{lat: 46.118942, lng: 150.402832}
    point_2 = %{lat: 21.913108, lng: -160.193712}
    point_3 = %{lat: 52.417520954378574, lng: 13.277235453275123}
    assert Geocalc.cross_track_distance_to(point_1, point_2, point_3) == -3_794_248.870228449
  end

  test "returns crossing parallels" do
    point_1 = %{lat: 46.1189424, lng: 150.402832}
    point_2 = %{lat: 21.9131082, lng: -160.1937128}
    latitude = 45.0
    assert Geocalc.crossing_parallels(point_1, point_2, latitude) == {:ok, 106.52361930066911, 155.95500236778844}
  end

  test "returns error message if no crossing parallels found" do
    point_1 = %{lat: 0, lng: 0}
    point_2 = %{lat: 180, lng: 90}
    latitude = 45.0
    assert Geocalc.crossing_parallels(point_1, point_2, latitude) == {:error, "Not found"}
  end
end
