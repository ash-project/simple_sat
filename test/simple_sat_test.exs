# SPDX-FileCopyrightText: 2024 simple_sat contributors <https://github.com/ash-project/simple_sat/graphs.contributors>
#
# SPDX-License-Identifier: MIT

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
             SimpleSat.solve([[1], [-6], [-5], [4], [3], [1, 2]])

    assert {:ok, [-1, 2, -3, 4, -5]} =
             SimpleSat.solve([[2], [-3], [4, 5], [-4, -1], [-5, -2], [-5, -3]])
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
