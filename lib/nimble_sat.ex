defmodule SimpleSat do
  @moduledoc """
  A simple, dependency free boolean satisfiability solver.

  This was created for folks having trouble running `picosat_elixir`
  to use as a drop-in replacement for Ash Framework, but feel free to use it in
  any way you see fit.

  SimpleSat expects to receive a list of lists of integers, where each integer
  represents a variable. If the integer is negative, it represents the negation
  of said variable.

  Additionally, SimpleSat expects to receive variables in "Conjunctive Normal Form" or CNF.
  This is the same interface that `picosat_elixir` expects. CNF is a conjunction of disjunctions.
  In other words, it is a list of statements that must *all be true*, where each statement is a list of
  variables where at *least one must be true*. For example:

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
  Provide a valid solution for a statement in CNF form
  """
  @spec solve([[integer]]) :: {:ok, [integer]} | {:error, :unsatisfiable}
  def solve(cnf_integer) do
    {statements, all_vars} =
      cnf_integer
      |> Enum.reduce({[], []}, fn statement, {statements, all_vars} ->
        {statement, all_vars} =
          Enum.reduce(statement, {[], all_vars}, fn var, {statement, all_vars} ->
            {[variable(var) | statement], [abs(var) | all_vars]}
          end)

        {[statement | statements], all_vars}
      end)

    all_vars = Enum.uniq(all_vars)

    Enum.find_value(all_vars, {:error, :unsatisfiable}, fn var ->
      if solution = find_solution(var, all_vars -- [var], statements) do
        {:ok, solution}
      end
    end)
  end

  defp find_solution(var, other_vars, statements, trail \\ []) do
    statements_with_true =
      guess_value(statements, var, true)

    case simplify(statements_with_true) do
      true ->
        [var | trail]

      false ->
        statements_with_false =
          guess_value(statements, var, false)

        case simplify(statements_with_false) do
          true ->
            [var | trail]

          false ->
            nil

          simplified_statements ->
            case other_vars do
              [] ->
                nil

              [next_var | rest] ->
                find_solution(next_var, rest, simplified_statements, [-var | trail])
            end
        end

      simplified_statements ->
        case other_vars do
          [] ->
            nil

          [next_var | rest] ->
            find_solution(next_var, rest, simplified_statements, [var | trail])
        end
    end
  end

  defp simplify(statements) do
    statements
    |> Enum.map(fn statement ->
      simplify_statement(statement)
    end)
    |> case do
      [] ->
        false

      statements ->
        cond do
          Enum.any?(statements, &(&1 == false)) ->
            false

          Enum.all?(statements, &(&1 == true)) ->
            true

          true ->
            statements
        end
    end
  end

  defp simplify_statement(true) do
    true
  end

  defp simplify_statement(statement) do
    if Enum.any?(statement, &true?/1) do
      true
    else
      if Enum.all?(statement, &false?/1) do
        false
      else
        statement
      end
    end
  end

  defp true?({:const, true}), do: true
  defp true?(_), do: false

  defp false?({:const, false}), do: true
  defp false?(_), do: false

  defp guess_value(statements, var, value) do
    var =
      if value == true do
        var
      else
        -var
      end

    Enum.map(statements, fn
      true ->
        true

      statement ->
        Enum.map(statement, fn
          {:variable, s_var} ->
            cond do
              s_var == var ->
                {:const, true}

              s_var == -var ->
                {:const, false}

              true ->
                {:variable, s_var}
            end

          other ->
            other
        end)
    end)
  end

  defp variable(var), do: {:variable, var}
end
