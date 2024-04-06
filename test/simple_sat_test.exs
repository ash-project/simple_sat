defmodule SimpleSatTest do
  use ExUnit.Case
  doctest SimpleSat

  test "solves a single variable statement" do
    assert {:ok, [1]} = SimpleSat.solve([[1]])
  end

  test "solves an obvious negation" do
    assert {:error, :unsatisfiable} = SimpleSat.solve([[1], [-1]])
  end

  test "solves a less obvious negation" do
    assert {:error, :unsatisfiable} = SimpleSat.solve([[1, 2], [-1, -2], [1], [2]])
  end

  test "solves for three variables" do
    assert {:ok, [2, 3]} = SimpleSat.solve([[1, 3], [2], [1, -2, 3]])
  end

  test "solves for many variables" do
    assert {:ok, [-1, 2, -3, -4, -5, 6, 7, -8]} =
             SimpleSat.solve([[7], [-8], [6], [-5], [-4], [-3], [2], [-1]])
  end

  @tag :regression
  test "solves this properly" do
    assert {:ok, [1, 2, 3, 4, -5, -6]} =
             SimpleSat.solve([[1], [-6], [-5], [4], [3], [1, 2]]) |> IO.inspect()
  end

  test "solves this crazy example" do
    SimpleSat.solve([
      [1],
      [-3],
      [-7],
      [6],
      [-5],
      [-4],
      [3, 2],
      [1, 2],
      [-7, -6, 5, 4, 3, -1, -2]
    ])
  end
end
