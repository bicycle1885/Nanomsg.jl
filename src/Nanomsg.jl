module Nanomsg

const libnanomsg = "libnanomsg"

# domains
const AF_SP     = Cint(1)
const AF_SP_RAW = Cint(2)

# protocols
const PAIR = Cint(1 << 4 + 0)
const PUB  = Cint(2 << 4 + 0)
const SUB  = Cint(2 << 4 + 1)
const REQ  = Cint(3 << 4 + 0)
const REP  = Cint(3 << 4 + 1)

const SUB_SUBSCRIBE   = Cint(1)
const SUB_UNSUBSCRIBE = Cint(2)

# send/recv flags
const DONTWAIT = Cint(1)

macro genfunc(ex)
    @assert ex.head == :(::)
    call = ex.args[1]
    @assert call.head == :call
    name = call.args[1]
    rettype = ex.args[2]
    argtypes = Expr(:tuple, [arg.args[2] for arg in call.args[2:end]]...)
    argnames = [arg.args[1] for arg in call.args[2:end]]
    esc(quote
        function $(name)($(argnames...))
            return ccall(($(Expr(:quote, Symbol("nn_", name))), libnanomsg), $(rettype), $(argtypes), $(argnames...))
        end
    end)
end

# Generate C binding functions.
@genfunc socket(domain::Cint, protocol::Cint)::Cint
@genfunc close(s::Cint)::Cint
@genfunc setsockopt(s::Cint, level::Cint, option::Cint, optval::Ptr{Void}, optvallen::Csize_t)::Cint
@genfunc getsockopt(s::Cint, level::Cint, option::Cint, optval::Ptr{Void}, optvallen::Ptr{Csize_t})::Cint
@genfunc bind(s::Cint, addr::Ptr{UInt8})::Cint
@genfunc connect(s::Cint, addr::Ptr{UInt8})::Cint
@genfunc shutdown(s::Cint, how::Cint)::Cint
@genfunc send(s::Cint, buf::Ptr{Void}, len::Csize_t, flags::Cint)::Cint
@genfunc recv(s::Cint, buf::Ptr{Void}, len::Csize_t, flags::Cint)::Cint
@genfunc sendmsg(s::Cint, msghdr::Ptr{Void}, flags::Cint)::Cint
@genfunc recvmsg(s::Cint, msghdr::Ptr{Void}, flags::Cint)::Cint

@genfunc allocmsg(size::Csize_t, type_::Cint)::Ptr{Void}
@genfunc reallocmsg(msg::Ptr{Void}, size::Csize_t)::Ptr{Void}
@genfunc freemsg(msg::Ptr{Void})::Cint

# @genfunc poll(fds::Ptr{Void}, nfds::Cint, timeout::Cint)::Cint

@genfunc errno()::Cint
@genfunc strerror(errnum::Cint)::Ptr{UInt8}

@genfunc get_statistic(s::Cint, stat::Cint)::UInt64

@genfunc device(s1::Cint, s2::Cint)::Cint

@genfunc term()::Void

setsockopt(s, level, option, optval) = setsockopt(s, level, option, pointer(optval), sizeof(optval))
send(s, data, flags=0) = send(s, pointer(data), sizeof(data), flags)
recv(s, data, flags=0) = recv(s, pointer(data), sizeof(data), flags)

end # module
