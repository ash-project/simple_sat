# SPDX-FileCopyrightText: 2024 simple_sat contributors <https://github.com/ash-project/simple_sat/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule SimpleSatTest do
  use ExUnit.Case
  use ExUnitProperties

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

  property "gives same unsat / sat status as Picosat" do
    variable = StreamData.filter(StreamData.integer(-5..5), &(&1 != 0))

    check all(
            statements <-
              list_of(list_of(variable, min_length: 1, max_length: 10),
                min_length: 0,
                max_length: 10
              ),
            max_runs: 100_000
          ) do
      case SimpleSat.solve(statements) do
        {:ok, []} ->
          assert {:ok, []} = Picosat.solve(statements)

        {:ok, solution} ->
          assert {:ok, _} = Picosat.solve(statements ++ [solution])

        {:error, :unsatisfiable} ->
          assert {:error, :unsatisfiable} = Picosat.solve(statements)
      end
    end
  end
end
