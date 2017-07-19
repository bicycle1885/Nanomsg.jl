using Nanomsg
using Base.Test

const nn = Nanomsg

@testset "PAIR" begin
    s1 = nn.socket(nn.AF_SP, nn.PAIR)
    s2 = nn.socket(nn.AF_SP, nn.PAIR)
    nn.bind(s1, "inproc://test")
    nn.connect(s2, "inproc://test")
    msg = "hello, nanomsg"
    nn.send(s1, msg)
    buf = Vector{UInt8}(1024)
    sz = nn.recv(s2, buf)
    nn.close(s1)
    nn.close(s2)
    @test sz == sizeof(msg)
    @test String(buf[1:sz]) == msg
end

@testset "PUBSUB" begin
    pub = nn.socket(nn.AF_SP, nn.PUB)
    sub1 = nn.socket(nn.AF_SP, nn.SUB)
    sub2 = nn.socket(nn.AF_SP, nn.SUB)
    nn.bind(pub, "inproc://test")
    nn.connect(sub1, "inproc://test")
    nn.connect(sub2, "inproc://test")
    nn.setsockopt(sub1, nn.SUB, nn.SUB_SUBSCRIBE, "")
    nn.setsockopt(sub2, nn.SUB, nn.SUB_SUBSCRIBE, "")
    msg = "hello, nanomsg"
    nn.send(pub, msg)
    buf1 = Vector{UInt8}(1024)
    buf2 = Vector{UInt8}(1024)
    sz1 = nn.recv(sub1, buf1)
    sz2 = nn.recv(sub2, buf2)
    nn.close(pub)
    nn.close(sub1)
    nn.close(sub2)
    @test sz1 == sz2 == sizeof(msg)
    @test String(buf1[1:sz1]) == String(buf2[1:sz2]) == msg
end
