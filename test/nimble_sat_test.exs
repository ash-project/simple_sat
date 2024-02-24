defmodule SimpleSatTest do
  use ExUnit.Case
  doctest SimpleSat

  test "solves a single variable statement" do
    assert {:ok, [1]} = SimpleSat.solve([[1]])
  end

  test "solves an obvious negation" do
    assert {:error, :unsatisfiable} = SimpleSat.solve([[1], [-1]])
  end

  test "solves for three variables" do
    assert {:ok, [2, 3]} = SimpleSat.solve([[1, 3], [2], [1, -2, 3]])
  end

  test "solves for many variables" do
    assert {:ok, [7, -8, 6, -5, -4, -3, 2, -1]} =
             SimpleSat.solve([[7], [-8], [6], [-5], [-4], [-3], [2], [-1]])
  end
end
