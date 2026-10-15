# SPDX-FileCopyrightText: 2024 simple_sat contributors <https://github.com/ash-project/simple_sat/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule SimpleSat do
  @moduledoc """
  A simple, dependency free boolean satisfiability solver implementing DPLL search.

  This was created for folks having trouble running `picosat_elixir`
  to use as a drop-in replacement for Ash Framework, but feel free to use it in
  any way you see fit.

  SimpleSat expects to receive a list of lists of integers, where each integer
  represents a variable. If the integer is negative, it represents the negation
  of said variable.

  Additionally, SimpleSat expects to receive variables in "Conjunctive Normal Form" or CNF.
  This is the same interface that `picosat_elixir` expects. CNF is a conjunction of disjunctions.
  In other words, it is a list of clauses that must *all be true*, where each clause is a list of
  literals where at *least one must be true*. For example:

  ```elixir
  # A AND (NOT A)
  [[1], [-1]]

  # A AND (A OR B)
  [[1], [1, 2]]

  # A AND B AND C
  [[1], [2], [3]]
  ```
  """

  @doc """
  Finds a satisfying assignment for a formula in CNF.

  Takes a list of clauses, where each clause is a list of non-zero integers
  (literals). Returns `{:ok, solution}` with one literal per variable, sorted by
  variable. Variables whose value doesn't affect the result are set to true.

  Returns `{:error, :unsatisfiable}` when no assignment satisfies every clause,
  including when any clause is empty.

  ## Examples

      iex> SimpleSat.solve([[1, 2, -3], [2, 3], [-2], [-1, 3]])
      {:ok, [1, -2, 3]}

      iex> SimpleSat.solve([[1], [1, 2]])
      {:ok, [1, 2]}

      iex> SimpleSat.solve([[1], [-1]])
      {:error, :unsatisfiable}
  """
  @spec solve([[integer]]) :: {:ok, [integer]} | {:error, :unsatisfiable}
  def solve(clauses)
  def solve([]), do: {:ok, []}

  def solve(clauses) do
    if Enum.any?(clauses, &(&1 == [])) do
      {:error, :unsatisfiable}
    else
      case dpll(clauses, %{}) do
        nil ->
          {:error, :unsatisfiable}

        assignment ->
          solution =
            clauses
            |> complete(assignment)
            |> Enum.map(fn
              {var, true} -> var
              {var, false} -> -var
            end)
            |> Enum.sort_by(&abs/1)

          {:ok, solution}
      end
    end
  end

  defp dpll(clauses, assignment) do
    case propagate(clauses, assignment) do
      :conflict ->
        nil

      {[], assignment} ->
        assignment

      {clauses, assignment} ->
        literal = branch_literal(clauses)

        try_literal(clauses, assignment, literal) ||
          try_literal(clauses, assignment, -literal)
    end
  end

  defp try_literal(clauses, assignment, literal) do
    case assign(clauses, MapSet.new([literal])) do
      :conflict -> nil
      clauses -> dpll(clauses, record(assignment, literal))
    end
  end

  # Repeatedly assign all unit clauses in one batch until none remain.
  defp propagate(clauses, assignment) do
    units =
      Enum.reduce(clauses, MapSet.new(), fn
        [literal], acc -> MapSet.put(acc, literal)
        _clause, acc -> acc
      end)

    cond do
      MapSet.size(units) == 0 ->
        {clauses, assignment}

      Enum.any?(units, &MapSet.member?(units, -&1)) ->
        :conflict

      true ->
        assignment = Enum.reduce(units, assignment, &record(&2, &1))

        case assign(clauses, units) do
          :conflict -> :conflict
          clauses -> propagate(clauses, assignment)
        end
    end
  end

  # Apply a set of true literals to every clause: drop satisfied clauses,
  # strip falsified literals, conflict if a clause becomes empty.
  defp assign(clauses, literals) do
    Enum.reduce_while(clauses, [], fn clause, acc ->
      case reduce_clause(clause, literals, []) do
        :satisfied -> {:cont, acc}
        [] -> {:halt, :conflict}
        remaining -> {:cont, [remaining | acc]}
      end
    end)
  end

  defp reduce_clause([], _literals, acc), do: acc

  defp reduce_clause([literal | rest], literals, acc) do
    cond do
      MapSet.member?(literals, literal) -> :satisfied
      MapSet.member?(literals, -literal) -> reduce_clause(rest, literals, acc)
      true -> reduce_clause(rest, literals, [literal | acc])
    end
  end

  # Branch on a literal from the shortest clause — satisfying it removes the
  # clause, and falsifying it shortens the clause towards a unit.
  defp branch_literal(clauses) do
    clauses
    |> Enum.min_by(&length/1)
    |> hd()
  end

  defp record(assignment, literal), do: Map.put(assignment, abs(literal), literal > 0)

  # Variables no clause ended up depending on are unconstrained, so any value
  # satisfies the formula. Default them to true so the solution covers every
  # input variable.
  defp complete(clauses, assignment) do
    for clause <- clauses, literal <- clause, reduce: assignment do
      acc -> Map.put_new(acc, abs(literal), true)
    end
  end
end
