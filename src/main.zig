const std = @import("std");
const io = std.io;

const GameError = error{
    WinnerNotDecidedError,
    DealError,
};

const Player = enum {
    no_one,
    alice,
    bob,
};

const Move = struct {
    i: u8,
    j: u8,
};

var board: [3][3]Player = [_][3]Player{[_]Player{Player.no_one} ** 3} ** 3;

pub fn main() anyerror!void {
    var current_player: Player = Player.alice;
    while (true) {
        if (decideWinner()) |winner| {
            printBoard();
            std.debug.print("Winner is {d}!\n", .{winner});
            break;
        } else |err| {
            if (err == GameError.WinnerNotDecidedError) {
                printBoard();
                std.debug.print("{}:\n", .{current_player});
                const move = inputMove() catch continue;
                if ((move.i >= 3) or (move.j >= 3)) {
                    continue;
                }
                if (board[move.i][move.j] != Player.no_one) {
                    std.debug.print("Please select an empty cell!\n", .{});
                    continue;
                }
                std.debug.print("{any}\n", .{move});
                board[move.i][move.j] = current_player;
                current_player = if (current_player == Player.alice) Player.bob else Player.alice;
                continue;
            } else if (err == GameError.DealError) {
                printBoard();
                std.debug.print("Deal!\n", .{});
                break;
            }
        }
    }
}

fn inputMove() !Move {
    var buf: [1024]u8 = undefined;
    const reader = io.getStdIn().reader();
    const line = (try reader.readUntilDelimiterOrEof(&buf, '\n')).?;
    var it = std.mem.split(u8, line, " ");
    const i: u8 = (try std.fmt.parseUnsigned(u8, it.next().?, 10));
    const j: u8 = (try std.fmt.parseUnsigned(u8, it.next().?, 10));
    return Move{ .i = i, .j = j };
}

fn printBoard() void {
    std.debug.print("+---+---+---+\n", .{});
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        std.debug.print("| {u} | {u} | {u} |\n", .{ toMarker(board[i][0]), toMarker(board[i][1]), toMarker(board[i][2]) });
        std.debug.print("+---+---+---+\n", .{});
    }
}

fn toMarker(player: Player) u8 {
    return switch (player) {
        .no_one => ' ',
        .alice => 'O',
        .bob => 'X',
    };
}

fn decideWinner() GameError!Player {
    var i: usize = 0;
    while (i < 3) : (i += 1) {
        const row = board[i];
        const candidate = row[0];
        if (candidate == Player.no_one) {
            continue;
        }
        if ((candidate == row[1]) and (candidate == row[2])) {
            return candidate;
        }
    }
    i = 0;
    while (i < 3) : (i += 1) {
        const candidate = board[0][i];
        if (candidate == Player.no_one) {
            continue;
        }
        if ((candidate == board[1][i]) and (candidate == board[2][i])) {
            return candidate;
        }
    }
    var candidate = board[0][0];
    if ((candidate != Player.no_one) and (candidate == board[1][1]) and (candidate == board[2][2])) {
        return candidate;
    }
    candidate = board[0][2];
    if ((candidate != Player.no_one) and (candidate == board[1][1]) and (candidate == board[2][0])) {
        return candidate;
    }

    var found_empty: bool = false;
    i = 0;
    while (i < 3) : (i += 1) {
        var j: usize = 0;
        while (j < 3) : (j += 1) {
            if (board[i][j] == Player.no_one) {
                found_empty = true;
                break;
            }
        }
        if (found_empty) {
            break;
        }
    }
    if (!found_empty) {
        return GameError.DealError;
    }

    return GameError.WinnerNotDecidedError;
}
