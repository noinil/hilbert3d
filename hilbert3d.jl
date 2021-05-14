#!/usr/bin/env julia

using ArgParse
using Printf

# smallest cube:
#
# local_1d_3d_map = Dict(1 => (-1, -1,  1),
#                        2 => ( 1, -1,  1),
#                        3 => ( 1, -1, -1),
#                        4 => (-1, -1, -1),
#                        5 => (-1,  1, -1),
#                        6 => ( 1,  1, -1),
#                        7 => ( 1,  1,  1),
#                        8 => (-1,  1,  1))

basic_curve = [-1 +1 +1 -1 -1 +1 +1 -1;
               -1 -1 -1 -1 +1 +1 +1 +1;
               +1 +1 -1 -1 -1 -1 +1 +1]

rot_eye = [1 0 0; 0 1 0; 0 0 1]
rot_x_c = [1 0 0; 0 0 1; 0 -1 0]
rot_x_a = [1 0 0; 0 0 -1; 0 1 0]
rot_y_c = [0 0 -1; 0 1 0; 1 0 0]
rot_y_a = [0 0 1; 0 1 0; -1 0 0]
rot_z_c = [0 1 0; -1 0 0; 0 0 1]
rot_z_a = [0 -1 0; 1 0 0; 0 0 1]

function hilbert3d(n_order::Int)
    # =========
    # variables
    # =========
    n_nodes = 8^n_order
    node_chain = zeros(Int, (3, n_nodes))

    if n_order == 1
        node_chain = basic_curve
    else
        size_node  = 8^(n_order - 1)
        for node in 1:8
            coor_shift = basic_curve[:, node] .* 2^(n_order-1)
            node_coors = hilbert3d(n_order - 1)

            if node == 1
                rot_mat = rot_z_c * rot_y_a
            elseif node == 2
                rot_mat = rot_z_a * rot_x_c
            elseif node == 3
                rot_mat = rot_eye
            elseif node == 4
                rot_mat = rot_z_c * rot_x_c
            elseif node == 5
                rot_mat = rot_z_a * rot_x_a
            elseif node == 6
                rot_mat = rot_eye
            elseif node == 7
                rot_mat = rot_z_c * rot_x_a
            elseif node == 8
                rot_mat = rot_z_a * rot_y_a
            end
            node_chain[:, (node - 1) * size_node + 1 : node * size_node] = rot_mat * node_coors .+ coor_shift
        end
    end
    return node_chain
end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "n_order"
        help     = "Order of the curve."
        required = true
        arg_type = Int
    end

    return parse_args(s)
end

if abspath(PROGRAM_FILE) == @__FILE__
    args = parse_commandline()
    curve = hilbert3d(args["n_order"])

    of_name = @sprintf("HILBERT_3D_CURVE_ORDER_%02d.dat", args["n_order"])
    of = open(of_name, "w")
    for i in 1:size(curve)[2]
        @printf(of, " %5d   %8d %8d %8d \n", i, curve[1, i], curve[2, i], curve[3, i])
    end
    close(of)
end
