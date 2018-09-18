@testset "Linear Parition" begin
  @test Canary.linearpartition(1,1,1) == 1:1
  @test Canary.linearpartition(20,1,1) == 1:20
  @test Canary.linearpartition(10,1,2) == 1:5
  @test Canary.linearpartition(10,2,2) == 6:10
end

@testset "Hilbert Code" begin
  @test Canary.hilbertcode([0,0], bits=1) == [0, 0]
  @test Canary.hilbertcode([0,1], bits=1) == [0, 1]
  @test Canary.hilbertcode([1,1], bits=1) == [1, 0]
  @test Canary.hilbertcode([1,0], bits=1) == [1, 1]
  @test Canary.hilbertcode([0,0], bits=2) == [0, 0]
  @test Canary.hilbertcode([1,0], bits=2) == [0, 1]
  @test Canary.hilbertcode([1,1], bits=2) == [0, 2]
  @test Canary.hilbertcode([0,1], bits=2) == [0, 3]
  @test Canary.hilbertcode([0,2], bits=2) == [1, 0]
  @test Canary.hilbertcode([0,3], bits=2) == [1, 1]
  @test Canary.hilbertcode([1,3], bits=2) == [1, 2]
  @test Canary.hilbertcode([1,2], bits=2) == [1, 3]
  @test Canary.hilbertcode([2,2], bits=2) == [2, 0]
  @test Canary.hilbertcode([2,3], bits=2) == [2, 1]
  @test Canary.hilbertcode([3,3], bits=2) == [2, 2]
  @test Canary.hilbertcode([3,2], bits=2) == [2, 3]
  @test Canary.hilbertcode([3,1], bits=2) == [3, 0]
  @test Canary.hilbertcode([2,1], bits=2) == [3, 1]
  @test Canary.hilbertcode([2,0], bits=2) == [3, 2]
  @test Canary.hilbertcode([3,0], bits=2) == [3, 3]

  @test Canary.hilbertcode(UInt64.([14,3,4])) == UInt64.([0x0,0x0,0xe25])
end

@testset "Mesh to Hilbert Code" begin
  let
    etc = Array{Float64}(undef, 2, 4, 6)
    etc[:, :, 1] = [2.0  3.0  2.0  3.0; 4.0  4.0  5.0  5.0]
    etc[:, :, 2] = [3.0  4.0  3.0  4.0; 4.0  4.0  5.0  5.0]
    etc[:, :, 3] = [4.0  5.0  4.0  5.0; 4.0  4.0  5.0  5.0]
    etc[:, :, 4] = [2.0  3.0  2.0  3.0; 5.0  5.0  6.0  6.0]
    etc[:, :, 5] = [3.0  4.0  3.0  4.0; 5.0  5.0  6.0  6.0]
    etc[:, :, 6] = [4.0  5.0  4.0  5.0; 5.0  5.0  6.0  6.0]

    code_exect = UInt64[0x0000000000000000 0x1555555555555555 0xffffffffffffffff 0x5555555555555555 0x6aaaaaaaaaaaaaaa 0xaaaaaaaaaaaaaaaa; 0x0000000000000000 0x5555555555555555 0xffffffffffffffff 0x5555555555555555 0xaaaaaaaaaaaaaaaa 0xaaaaaaaaaaaaaaaa]

    code = centroidtocode(MPI.COMM_SELF, etc)

    @test code == code_exect
  end

  let
    nelem = 1
    d = 2

    etc = Array{Float64}(undef, d, d^2, nelem)
    etc[:, :, 1] = [2.0  3.0  2.0  3.0; 4.0  4.0  5.0  5.0]
    code = centroidtocode(MPI.COMM_SELF, etc)

    @test code == zeros(eltype(code), d, nelem)
  end
end

@testset "Vertex Ordering" begin
  @test ((1,), 1) == Canary.vertsortandorder(1)

  @test ((1,2), 1) == Canary.vertsortandorder(1, 2)
  @test ((1,2), 2) == Canary.vertsortandorder(2, 1)

  @test ((1,2,3), 1) == Canary.vertsortandorder(1, 2, 3)
  @test ((1,2,3), 2) == Canary.vertsortandorder(3, 1, 2)
  @test ((1,2,3), 3) == Canary.vertsortandorder(2, 3, 1)
  @test ((1,2,3), 4) == Canary.vertsortandorder(2, 1, 3)
  @test ((1,2,3), 5) == Canary.vertsortandorder(3, 2, 1)
  @test ((1,2,3), 6) == Canary.vertsortandorder(1, 3, 2)

  @test ((1,2,3,4), 1) == Canary.vertsortandorder(1, 2, 3, 4)
  @test ((1,2,3,4), 2) == Canary.vertsortandorder(1, 3, 2, 4)
  @test ((1,2,3,4), 3) == Canary.vertsortandorder(2, 1, 3, 4)
  @test ((1,2,3,4), 4) == Canary.vertsortandorder(2, 4, 1, 3)
  @test ((1,2,3,4), 5) == Canary.vertsortandorder(3, 1, 4, 2)
  @test ((1,2,3,4), 6) == Canary.vertsortandorder(3, 4, 1, 2)
  @test ((1,2,3,4), 7) == Canary.vertsortandorder(4, 2, 3, 1)
  @test ((1,2,3,4), 8) == Canary.vertsortandorder(4, 3, 2, 1)
end

@testset "Mesh" begin
  let
    (etv, etc, fc) = brickmesh((2:5,4:6), (false,true))
    etv_expect = [ 1  2  5  6
                   2  3  6  7
                   3  4  7  8
                   5  6  9 10
                   6  7 10 11
                   7  8 11 12]'
    fc_expect = Array{Int64,1}[[4, 4, 1, 2],
                               [5, 4, 2, 3],
                               [6, 4, 3, 4]]

    @test etv == etv_expect
    @test fc == fc_expect
    @test etc[:,:,1] == [2 3 2 3
                         4 4 5 5]
    @test etc[:,:,5] == [3 4 3 4
                         5 5 6 6]
  end

  let
    (etv, etc, fc) = brickmesh((-1:2:1,-1:2:1,-1:1:1), (true,true,true))
    etv_expect = [1   5
                  2   6
                  3   7
                  4   8
                  5   9
                  6  10
                  7  11
                  8  12]

    fc_expect = Array{Int64,1}[[1, 2, 1, 3, 5,  7],
                               [1, 4, 1, 2, 5,  6],
                               [2, 2, 5, 7, 9, 11],
                               [2, 4, 5, 6, 9, 10],
                               [2, 6, 1, 2, 3,  4]]

    @test etv == etv_expect
    @test fc == fc_expect

    @test etc[:,:,1] == [-1  1 -1  1 -1  1 -1  1
                         -1 -1  1  1 -1 -1  1  1
                         -1 -1 -1 -1  0  0  0  0]

    @test etc[:,:,2] == [-1  1 -1  1 -1  1 -1  1
                         -1 -1  1  1 -1 -1  1  1
                          0  0  0  0  1  1  1  1]
  end

  let
    x = (-1:2:10,-1:1:1,-4:1:1)
    p = (true,false,true)

    (etv, etc, fc) = brickmesh(x,p)

    n = 50
    (etv_parts, etc_parts, fc_parts) = brickmesh(x,p, part=1, numparts=n)
    for j=2:n
      (etv_j, etc_j, fc_j) = brickmesh(x,p, part=j, numparts=n)
      etv_parts = cat(etv_parts, etv_j; dims=2)
      etc_parts = cat(etc_parts, etc_j; dims=3)
    end

    @test etv == etv_parts
    @test etc == etc_parts
  end
end

@testset "Connect" begin
  let
    comm = MPI.COMM_SELF
    mesh = connectmesh(comm, partition(comm, brickmesh((0:4,5:9),
                                                       (false,true))...)...)

    nelem = 16

    @test mesh[:elemtocoord][:,:, 1] == [0 1 0 1; 5 5 6 6]
    @test mesh[:elemtocoord][:,:, 2] == [1 2 1 2; 5 5 6 6]
    @test mesh[:elemtocoord][:,:, 3] == [1 2 1 2; 6 6 7 7]
    @test mesh[:elemtocoord][:,:, 4] == [0 1 0 1; 6 6 7 7]
    @test mesh[:elemtocoord][:,:, 5] == [0 1 0 1; 7 7 8 8]
    @test mesh[:elemtocoord][:,:, 6] == [0 1 0 1; 8 8 9 9]
    @test mesh[:elemtocoord][:,:, 7] == [1 2 1 2; 8 8 9 9]
    @test mesh[:elemtocoord][:,:, 8] == [1 2 1 2; 7 7 8 8]
    @test mesh[:elemtocoord][:,:, 9] == [2 3 2 3; 7 7 8 8]
    @test mesh[:elemtocoord][:,:,10] == [2 3 2 3; 8 8 9 9]
    @test mesh[:elemtocoord][:,:,11] == [3 4 3 4; 8 8 9 9]
    @test mesh[:elemtocoord][:,:,12] == [3 4 3 4; 7 7 8 8]
    @test mesh[:elemtocoord][:,:,13] == [3 4 3 4; 6 6 7 7]
    @test mesh[:elemtocoord][:,:,14] == [2 3 2 3; 6 6 7 7]
    @test mesh[:elemtocoord][:,:,15] == [2 3 2 3; 5 5 6 6]
    @test mesh[:elemtocoord][:,:,16] == [3 4 3 4; 5 5 6 6]

    @test mesh[:elemtoelem] ==
      [1   1   4  4  5  6   6  5   8   7  10   9  14   3   2  15
       2  15  14  3  8  7  10  9  12  11  11  12  13  13  16  16
       6   7   2  1  4  5   8  3  14   9  12  13  16  15  10  11
       4   3   8  5  6  1   2  7  10  15  16  11  12   9  14  13]

    @test mesh[:elemtoface] ==
      [1  2  2  1  1  1  2  2  2  2  2  2  2  2  2  2
       1  1  1  1  1  1  1  1  1  1  2  2  2  1  1  2
       4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4
       3  3  3  3  3  3  3  3  3  3  3  3  3  3  3  3]

    @test mesh[:elemtoordr] == ones(Int, size(mesh[:elemtoordr]))

    @test mesh[:elems] == 1:nelem
    @test mesh[:realelems] == 1:nelem
    @test mesh[:ghostelems] == nelem.+(1:0)

    @test length(mesh[:sendelems]) == 0

    @test mesh[:nabrtorank] == Int[]
    @test mesh[:nabrtorecv] == UnitRange{Int}[]
    @test mesh[:nabrtosend] == UnitRange{Int}[]
  end
end

@testset "Get Partition" begin
  let
    Nelem = 150
    (so, ss, rs) = Canary.getpartition(MPI.COMM_SELF, Nelem:-1:1)
    @test so == Nelem:-1:1
    @test ss == [1, Nelem+1]
    @test rs == [1, Nelem+1]
  end

  let
    Nelem = 111
    code = [ones(1,Nelem); collect(Nelem:-1:1)']
    (so, ss, rs) = Canary.getpartition(MPI.COMM_SELF, Nelem:-1:1)
    @test so == Nelem:-1:1
    @test ss == [1, Nelem+1]
    @test rs == [1, Nelem+1]
  end
end

@testset "Partition" begin
  (etv, etc, fc) = brickmesh((-1:2:1,-1:2:1,-2:1:2), (true,true,true))
  (netv, netc, nfc) = partition(MPI.COMM_SELF, etv, etc, fc)
  @test etv == netv
  @test etc == netc
  @test fc == nfc
end
