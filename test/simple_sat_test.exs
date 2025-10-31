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

  test "solves https://github.com/ash-project/simple_sat/issues/2" do
    problem = [
      [-3, 36, 7],
      [-3, -42, -48],
      [-49, -47, -41],
      [8, -40, 17],
      [-21, -31, -39],
      [36, -22, 49],
      [27, 38, 14],
      [15, -18, 6],
      [6, 7, -43],
      [34, -7, 23],
      [2, 14, -13],
      [2, 47, -42],
      [-33, -35, 3],
      [44, 40, 49],
      [50, 36, 31],
      [-36, -3, -37],
      [26, -29, 43],
      [15, 29, -45],
      [24, -11, 18],
      [-47, -26, 6],
      [-50, -33, -10],
      [32, 6, 16],
      [-34, 37, 41],
      [7, -28, -17],
      [-44, 46, 19],
      [7, 22, -48],
      [3, 39, 34],
      [31, 46, -43],
      [-27, 32, 23],
      [37, -50, -18],
      [20, 5, 11],
      [-45, -24, 6],
      [-34, -23, -14],
      [-22, 21, 20],
      [-17, 50, 24],
      [-25, -24, -27],
      [3, 35, 21],
      [-26, 47, -36],
      [-28, -45, 49],
      [-21, -6, 12],
      [-17, -15, -39],
      [41, 2, -14],
      [25, 36, -23],
      [-39, -3, -40],
      [50, 20, 35],
      [27, 31, -39],
      [45, -15, -40],
      [34, 50, 35],
      [-1, -48, 12],
      [18, -35, -30],
      [27, -24, -25],
      [-4, -33, -12],
      [-43, -24, -37],
      [-37, 31, -44],
      [-9, -38, 14],
      [33, -16, 34],
      [4, -35, -5],
      [-3, -21, -19],
      [-35, -36, -29],
      [7, -43, 36],
      [30, 14, 41],
      [-35, -24, -7],
      [35, -42, 6],
      [-1, -15, 39],
      [27, 49, -16],
      [-37, 49, -10],
      [50, -46, -3],
      [-41, 20, 34],
      [-1, 23, 28],
      [-12, -30, -20],
      [-24, 29, -37],
      [12, 5, -44],
      [-6, -2, 48],
      [-2, -49, -43],
      [1, -50, 24],
      [-7, -50, -44],
      [-41, 43, 4],
      [13, 15, -11],
      [-3, -11, 23],
      [33, 48, 41]
    ]

    assert {:ok, solution} =
             SimpleSat.solve(problem)

    assert {:ok, _result} = Picosat.solve([solution | problem])
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
