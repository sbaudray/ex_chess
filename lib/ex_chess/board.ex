defmodule ExChess.Board do
  defmodule Piece do
    defstruct [:color, :kind]
  end

  @doc """
    key: {File, Rank} 
  """
  def new do
    %{
      "00" => %Piece{color: :white, kind: :rook},
      "10" => %Piece{color: :white, kind: :night},
      "20" => %Piece{color: :white, kind: :bishop},
      "30" => %Piece{color: :white, kind: :queen},
      "40" => %Piece{color: :white, kind: :king},
      "50" => %Piece{color: :white, kind: :bishop},
      "60" => %Piece{color: :white, kind: :night},
      "70" => %Piece{color: :white, kind: :rook},
      "01" => %Piece{color: :white, kind: :pawn},
      "11" => %Piece{color: :white, kind: :pawn},
      "21" => %Piece{color: :white, kind: :pawn},
      "31" => %Piece{color: :white, kind: :pawn},
      "41" => %Piece{color: :white, kind: :pawn},
      "51" => %Piece{color: :white, kind: :pawn},
      "61" => %Piece{color: :white, kind: :pawn},
      "71" => %Piece{color: :white, kind: :pawn},
      "06" => %Piece{color: :black, kind: :pawn},
      "16" => %Piece{color: :black, kind: :pawn},
      "26" => %Piece{color: :black, kind: :pawn},
      "36" => %Piece{color: :black, kind: :pawn},
      "46" => %Piece{color: :black, kind: :pawn},
      "56" => %Piece{color: :black, kind: :pawn},
      "66" => %Piece{color: :black, kind: :pawn},
      "76" => %Piece{color: :black, kind: :pawn},
      "07" => %Piece{color: :black, kind: :rook},
      "17" => %Piece{color: :black, kind: :night},
      "27" => %Piece{color: :black, kind: :bishop},
      "37" => %Piece{color: :black, kind: :queen},
      "47" => %Piece{color: :black, kind: :king},
      "57" => %Piece{color: :black, kind: :bishop},
      "67" => %Piece{color: :black, kind: :night},
      "77" => %Piece{color: :black, kind: :rook}
    }
  end

  def key({file, rank}) do
    "#{file}#{rank}"
  end

  def piece(board, {file, rank}) do
    Map.get(board, key({file, rank}))
  end

  def print(positions) do
    board =
      for rank <- 7..0, file <- 0..7, into: "" do
        piece = piece(positions, {file, rank})

        case {file, piece} do
          {7, %Piece{kind: kind}} ->
            Atom.to_string(kind) |> (String.first() |> (fn s -> s <> "\n" end).())

          {7, nil} ->
            "\s\n"

          {_, %Piece{kind: kind}} ->
            Atom.to_string(kind) |> String.first()

          _ ->
            "\s"
        end
      end

    IO.puts(board)
  end

  def enemy_on_square?(board, pos, piece) do
    on_square = piece(board, pos)

    case on_square do
      %Piece{} -> not match_color(on_square, piece)
      _ -> false
    end
  end

  def match_color(%Piece{color: color}, %Piece{color: color}), do: true

  def match_color(_, _), do: false

  def out_of_bounds?({file, rank}) do
    cond do
      file > 7 -> true
      rank > 7 -> true
      file < 0 -> true
      rank < 0 -> true
      true -> false
    end
  end

  def legal_moves(board, pos) do
    piece = piece(board, pos)

    legal_moves(board, piece, pos)
  end

  def legal_moves(board, %Piece{kind: :rook} = piece, {file, rank}) do
    ranges = [
      (rank + 1)..7,
      (rank - 1)..0,
      (file + 1)..7,
      (file - 1)..0
    ]

    for range <- ranges do
      Enum.reduce_while(range, [], fn value, acc ->
        pos = {file, value}

        cond do
          out_of_bounds?(pos) -> {:halt, acc}
          enemy_on_square?(board, pos, piece) -> {:halt, [pos | acc]}
          piece_on_square?(board, pos) -> {:halt, acc}
          true -> {:cont, [pos | acc]}
        end
      end)
    end
  end

  def legal_moves(board, %Piece{kind: :pawn} = piece, {file, rank}) do
    range =
      case {piece.color, rank} do
        {:black, 6} -> 5..4
        {:black, other} -> [other - 1]
        {:white, 1} -> 2..3
        {:white, other} -> [other + 1]
      end

    Enum.reduce_while(range, [], fn currank, acc ->
      pos = {file, currank}

      with false <- out_of_bounds?(pos),
           false <- enemy_on_square?(board, pos, piece),
           false <- piece_on_square?(board, pos) do
        {:cont, [pos | acc]}
      else
        _ -> {:halt, acc}
      end
    end)
  end

  def legal_moves(board, %Piece{kind: :night}, {file, rank}) do
    deltas =
      for x <- [2, -2], y <- [1, -1] do
        [{x, y}, {y, x}]
      end
      |> List.flatten()

    for {x, y} <- deltas,
        pos = {file + x, rank + y},
        out_of_bounds?(pos) == false,
        piece_on_square?(board, pos) == false do
      pos
    end
  end

  def legal_moves(board, %Piece{kind: :king}, {file, rank}) do
    deltas = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

    for {x, y} <- deltas,
        pos = {file + x, rank + y},
        out_of_bounds?(pos) == false,
        piece_on_square?(board, pos) == false do
      pos
    end
  end

  def piece_on_square?(board, pos) do
    case Map.get(board, key(pos)) do
      nil -> false
      _ -> true
    end
  end

  def move(board, old_pos, new_pos) do
    piece = piece(board, old_pos)

    if new_pos in legal_moves(board, old_pos) do
      Map.delete(board, key(old_pos))
      |> Map.put(key(new_pos), piece)
    end
  end

  def run do
    board = new()

    move(board, {4, 1}, {4, 3})
    |> move({4, 6}, {4, 4})
    |> move({6, 0}, {5, 2})
    |> move({4, 7}, {4, 6})
    |> print
  end
end
